module Spree
  class OrderContents
    attr_accessor :order, :currency, :bscDynamicPrice, :bscSpec

    def initialize(order)
      @order = order
    end

    # Get current line item for variant if exists
    # Add variant qty to line_item
    def add(variant, quantity = 1, currency = nil, shipment = nil)
      line_item = order.find_line_item_by_variant(variant)
     
      # 29/12/13 DH: Only allow 1 variant sample per order
      #unless variant.option_value("silk") == "Sample" and line_item
      #  line_item = add_to_line_item(line_item, variant, quantity, currency, shipment)
      #end
      
      # 3/3/14 DH: Previously only allowing 1 sample variant per order but since the BSC spec is per variant
      #            line_item then can only allow 1 variant per order 
      #            (diff variants, eg pencil pleat and deep pencil pleat, of same silk still allowed)
      if line_item
        return line_item
      else
        line_item = add_to_line_item(line_item, variant, quantity, currency, shipment)
      end
      
      line_item
      
    end

    # Get current line item for variant
    # Remove variant qty from line_item
    def remove(variant, quantity = 1, shipment = nil)
      line_item = order.find_line_item_by_variant(variant)

      unless line_item
        raise ActiveRecord::RecordNotFound, "Line item not found for variant #{variant.sku}"
      end

      remove_from_line_item(line_item, variant, quantity, shipment)
    end

    private

    def add_to_line_item(line_item, variant, quantity, currency=nil, shipment=nil)
      if line_item
        line_item.target_shipment = shipment
        line_item.quantity += quantity.to_i
        line_item.currency = currency unless currency.nil?
      else
        line_item = order.line_items.new(quantity: quantity, variant: variant)
        line_item.target_shipment = shipment
        if currency
          line_item.currency = currency unless currency.nil?
          line_item.price    = variant.price_in(currency).amount
        else
          line_item.price    = variant.price
        end
      end
      
      catch(:sample) {
        # 29/12/13 DH: If a dynamic price was returned from the Products Show then use it to populate the line item
        if @bscDynamicPrice
          line_item.price    = @bscDynamicPrice
          line_item.bsc_spec = @bscSpec
          
          # 29/4/14 DH: Checkout the date diff from the old spec population doode!
          #             Anyway, now populating a separate table rather than just storing an unparsed string
          #             The string is used for the RomanCart integration until the order has "Status Complete",
          #             otherwise it would lead to "data redundancy" and risk "data anomalies"!
          
          #line_item.create_bsc_req!(width: 20, drop: 20, lining: "You", heading: "Beauty")
          
          if line_item.bsc_spec
            begin
              line_item.create_bsc_req(Spree::BscReq.createBscReqHash(line_item.bsc_spec))
            rescue ActiveRecord::UnknownAttributeError # To catch the default "spec"=>"N/A" for samples
              if line_item.bsc_spec.eql?("N/A")
                throw :sample # Which is caught above to allow adding a sample without later inevitable errors
              else
                raise "Unknown BSC spec of: #{line_item.bsc_spec}"
              end
            end

            if line_item.bsc_req.invalid?
              raise "The BSC requirement set is missing a value"
            end
            
            # 17/7/14 DH: Now check that the price is valid for the spec and that we haven't been hacked!
            
            # 17/7/14 DH: Need to save the line item to be able to access it via the Active Record association 
            #             (via the inverse of the FK entry in 'spree_line_items')
            line_item.save
            
            if line_item.bsc_req.dynamic_price_invalid?
              raise "The dynamic price is incorrect"
            end

=begin
            reqs = Hash.new
            line_item.bsc_spec.split(',').each do |req|
              category, value = req.split('=')
              reqs[category] = value
            end
            line_item.create_bsc_req!(width: reqs["width"], drop: reqs["drop"], lining: reqs["lining"], heading: reqs["heading"])
=end
          end # END: 'if line_item.bsc_spec'
        
        end # END: 'if @bscDynamicPrice'
      } # END: 'catch(:sample)'


      line_item.save
            
      order.reload
      line_item
    end

    def remove_from_line_item(line_item, variant, quantity, shipment=nil)
      line_item.quantity += -quantity
      line_item.target_shipment= shipment

      if line_item.quantity == 0
        Spree::OrderInventory.new(order).verify(line_item, shipment)
        line_item.destroy
      else
        line_item.save!
      end

      order.reload
      line_item
    end

  end
end
