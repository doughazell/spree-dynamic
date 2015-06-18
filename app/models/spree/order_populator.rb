module Spree
  class OrderPopulator
    attr_accessor :order, :currency
    attr_reader :errors

    def initialize(order, currency)
      @order = order
      @currency = currency
      @errors = ActiveModel::Errors.new(self)
    end

    def populate(variant_id, quantity, options = {}, price, spec)

      # 23/2/15 DH: Passing dynamic price and spec from web page
      @order.contents.bscDynamicPrice = BigDecimal.new(price)
      @order.contents.bscSpec = spec
    
      ActiveSupport::Deprecation.warn "OrderPopulator is deprecated and will be removed from Spree 3, use OrderContents with order.contents.add instead.", caller
      # protect against passing a nil hash being passed in
      # due to an empty params[:options]
      attempt_cart_add(variant_id, quantity, options || {})
      valid?
    end

    def valid?
      errors.empty?
    end

    private

    def attempt_cart_add(variant_id, quantity, options = {})
      quantity = quantity.to_i
      # 2,147,483,647 is crazy.
      # See issue #2695.
      if quantity > 2_147_483_647
        errors.add(:base, Spree.t(:please_enter_reasonable_quantity, scope: :order_populator))
        return false
      end

      variant = Spree::Variant.find(variant_id)
      begin
        @order.contents.add(variant, quantity, options.merge(currency: currency))
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, e.record.errors.messages.values.join(" "))
      end
      
      # 18/6/15 DH: Passing BSC Req errors back to the web after Spree-2.4 changed the mechanism it used.
      line_item = @order.line_item
      if line_item && line_item.bsc_req_id == -1
        errors.add(:base, line_item.bsc_req.errors.messages.values.join(" "))
      end
    end
  end
end
