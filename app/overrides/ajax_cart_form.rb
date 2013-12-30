Deface::Override.new(:virtual_path => 'spree/products/show',
                     :name => 'my_remote_cart_form',                
                     :replace => "code[erb-loud]:contains('form_for :order, :url => populate_orders_path do |f|')",
                     :erb => "<%= form_for :order, :url => populate_orders_path, :remote => true do |f| %>")
