module Spree
  module DynamicHelper
  
    def lineItemToOrderItem(line_item)
      spec = line_item.bsc_spec
      silk_name = Spree::Variant.find_by_id(line_item.variant_id).name
      silk_sku  = Spree::Variant.find_by_id(line_item.variant_id).sku

      order_item = "#{silk_name}-#{silk_sku}(#{spec})"

    end

  end
end