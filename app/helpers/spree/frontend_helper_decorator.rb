module Spree
  module FrontendHelper

    # 5/6/15 DH: Taken from '2-4-stable::spree/core/app/helpers/spree/base_helper.rb'
    def link_to_cart(text = nil)
      text = text ? h(text) : Spree.t('cart')
      css_class = nil

      # 23/9/16 DH: Removing "<span class='glyphicon glyphicon-shopping-cart'></span>" which could have been done via overrides

      if simple_current_order.nil? or simple_current_order.item_count.zero?
        text = "#{text}: (#{Spree.t('empty')})"
        css_class = 'empty'
      else
        text = "#{text}: (#{simple_current_order.item_count})  <span class='amount'>#{simple_current_order.display_total.to_html}</span>"
        css_class = 'full'
      end

      link_to text.html_safe, spree.cart_path, :class => "cart-info #{css_class}"
    end
  end
end

=begin
# 21/9/16 DH: Finding out why I monkey-patched 'link_to_cart'...
#             ...because the Deface Nokogiri CSS code to remove added span was not found...
#             ...prob because it was the output of a helper method called via ERB, so was hidden from Deface Nokogiri.

~/src/spree-dynamic
spree-3.0.0 (branch: 3-0-stable) with (ruby-2.2.1 OR ruby-2.2.2) in 'frontend/app/helpers/spree/frontend_helper.rb':


    def link_to_cart(text = nil)
      text = text ? h(text) : Spree.t('cart')
      css_class = nil

      if simple_current_order.nil? or simple_current_order.item_count.zero?
        text = "<span class='glyphicon glyphicon-shopping-cart'></span> #{text}: (#{Spree.t('empty')})"
        css_class = 'empty'
      else
        text = "<span class='glyphicon glyphicon-shopping-cart'></span> #{text}: (#{simple_current_order.item_count})  <span class='amount'>#{simple_current_order.display_total.to_html}</span>"
        css_class = 'full'
      end
      
      # ------------------------------------------------------------------------------------------
      # 23/9/16 DH: Need to change the 'text' of the 'link_to' ERB with the Decorator...somehow...
      # ------------------------------------------------------------------------------------------
      
      link_to text.html_safe, spree.cart_path, :class => "cart-info #{css_class}"
    end


~/src/temp/spree-dynamic-2-4
spree-2.4.7.beta (branch: 2-4-stable) with ruby-2.2.1 in 'core/app/helpers/spree/base_helper.rb':

=end
