module Spree
  class OrderPopulator
    attr_accessor :order, :currency
    attr_reader :errors

    def initialize(order, currency)
      @order = order
      @currency = currency
      @errors = ActiveModel::Errors.new(self)
    end

    #
    # Parameters can be passed using the following possible parameter configurations:
    #
    # * Single variant/quantity pairing
    # +:variants => { variant_id => quantity }+
    #
    # * Multiple products at once
    # +:products => { product_id => variant_id, product_id => variant_id }, :quantity => quantity+
    def populate(from_hash)

      # 17/10/13 DH: Store the dynamic BSC price for addition at 'OrderContents.add_to_line_item()' stage.
      if from_hash[:price]
        @order.contents.bscDynamicPrice = BigDecimal.new(from_hash[:price])
      end
    
      # 22/11/13 DH: Now storing the BSC spec in the description part of the line item (so using same transfer mechanism as 'price')
      #              Then we can add multiple curtains to the same order.
      if from_hash[:spec]
        @order.contents.bscSpec = from_hash[:spec]
      end
                
      from_hash[:products].each do |product_id,variant_id|
      
        # 17/10/13 DH: If the hash contains a 'price' then set the variant's price
        #              However this permanantly changes the variant's price so effects later use! 
        #if from_hash[:price]
        #  Spree::Variant.find(variant_id).default_price =  Spree::Price.new(:amount => from_hash[:price], :currency => currency)
        #end
      
        attempt_cart_add(variant_id, from_hash[:quantity])
      end if from_hash[:products]

      from_hash[:variants].each do |variant_id, quantity|
      
        attempt_cart_add(variant_id, quantity)
      end if from_hash[:variants]

=begin
      # 18/11/13 DH: Store the curtains spec in the 'Order.special_instructions'
      #              Needs to be stored after 'attempt_cart_add' otherwise gets deleted for a new order.
      if from_hash[:spec]
        @order.special_instructions = from_hash[:spec]
        # If the order isn't saved here then we loose the curtains spec (since 'special instructions' is normally used for 
        # delivery info and doesn't get saved at this stage in the normal Spree Checkout state transition process)
        @order.save!
      end
=end

      valid?
    end

    def valid?
      errors.empty?
    end

    private

    def attempt_cart_add(variant_id, quantity)
      quantity = quantity.to_i
      # 2,147,483,647 is crazy.
      # See issue #2695.
      if quantity > 2_147_483_647
        errors.add(:base, Spree.t(:please_enter_reasonable_quantity, :scope => :order_populator))
        return false
      end

      variant = Spree::Variant.find(variant_id)
      if quantity > 0

        line_item = @order.contents.add(variant, quantity, currency)

        if (line_item.respond_to?(:bsc_req_id))
          bsc_req_id = line_item.bsc_req_id
        end
        
        #unless line_item.valid?
        unless bsc_req_id.nil? && line_item.valid?
          errors.add(:base, line_item.errors.messages.values.join(" "))
          @order.contents.remove(variant)
          return false
        end
      
      end
    end
  end
end
