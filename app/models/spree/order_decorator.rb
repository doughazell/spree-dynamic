#class DynamicOrder < Spree::Order
Spree::Order.class_eval do

=begin
  # 15/6/15 DH: Trying to just adapt existing Spree code without lifting the whole method
  #             which may change in future releases
  def merge!(order, user = nil)
    super
    
    self.line_items.each do |line_item|
      if line_item.quantity > 1
        altered = true
        line_item.quantity = 1
        line_item.save!
      end
    end
    
    if altered
      updater.update_item_count
      updater.update_item_total
      updater.persist_totals
    end
  end
=end

  def merge!(order, user = nil)
    order.line_items.each do |other_order_line_item|
      next unless other_order_line_item.currency == currency

      # Compare the line items of the other order with mine.
      # Make sure you allow any extensions to chime in on whether or
      # not the extension-specific parts of the line item match
      #
      # 16/6/15 DH: See https://guides.spreecommerce.com/release_notes/spree_2_4_0.html
      #
      current_line_item = self.line_items.detect { |my_li|
                    my_li.variant == other_order_line_item.variant &&
                    self.line_item_comparison_hooks.all? { |hook|
                      self.send(hook, my_li, other_order_line_item.serializable_hash)
                    }
                  }
      if current_line_item
        # 15/6/15 DH: Spree-dynamic only allows 1 of each variant to prevent spec difference clashes!
        #current_line_item.quantity += other_order_line_item.quantity
        #current_line_item.save!
      else
        other_order_line_item.order_id = self.id
        other_order_line_item.save!
      end
    end

    self.associate_user!(user) if !self.user && !user.blank?

    updater.update_item_count
    updater.update_item_total
    updater.persist_totals

    # So that the destroy doesn't take out line items which may have been re-assigned
    order.line_items.reload
    order.destroy
  end

end
