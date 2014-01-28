# spreeBSC adaptions to Spree #

### Dynamic pricing parameters ###

1. Monkey-patch 'Spree::AppConfiguration' in 'config/initializers/spree_bsc.rb' to add the dynamic pricing params 
   \+ Rollover help text, to the Spree config (these then get added to the 'spree_preferences' DB table along with 
   those from 'spree.rb' 
   and the '/admin' interface).
2. Send params to browser DOM as hidden **data-** values in 'views/spree/products/show.html.erb'.
3. Retrieve sent values via javascript that is executed when the page loads. The dynamic pricing algorithm is 
   written in CoffeeScript and interfaces with the DOM via jQuery in 'assets/javascripts/store/product.js.coffee'.
4. The '<%= hidden_field_tag :price %>' in the '<%= form_for :order, ... %>' of 'views/spree/products/show.html.erb'
   is then populated with the dynamically created price and sent to 'populate_orders_path' or 
   'controllers/spree/orders_controller.rb' ('rake routes' will explain why).
5. The 'price' parameter is then forwarded onto the data model 'Spree::OrderPopulator.populate' method 
   and stored in the order.
6. This price is then used when the order is listed by data model 'Spree::OrderContents.add_to_line_item'.

### Required curtain spec ###

The curtains spec is returned via the '<%= hidden_field_tag :spec, "N/A" %>', in a similar manner to the dynamic 
price, and saved in the order by 'models/spree/order_populator.rb::populate'.

Previously in Rails 3 this was added to the 'Spree::LineItem' via a decorator adding 'attr_accessible :bsc_spec' but this was changed in Rails 4 to 'params.permit(:bsc_spec)' in 'controllers/spree/orders_controller.rb::populate'.  "With strong parameters, Action Controller parameters are forbidden to be used in Active Model mass assignments until they have been whitelisted."

If the specific variant's spec was changed for the duration of the order (via adding an additional column, 'bsc_spec', to the 'spree_variants' DB table using a migration) then this would allow multiple curtain variants (based on material and heading type eg pencil pleat) to be added to the 
same order **but not multiple versions of the same variant with different parameters AND CAUSE A DATA RACE WHEN 
MULTIPLE PEOPLE ARE ORDERING A CURTAIN OF THE SAME VARIANT AT THE SAME TIME!**

### Curtain category tree ###

If the 'views/spree/shared/products' partial view has been called from the 'home' URL controller and the 'taxon' 
(item classification, taxonomy) has the same name as the "product" then we are selecting a curtain category.

The price entered, via the '/admin' interface, for the curtain type is "0" and is not displayed.

The link for the curtain types on the home page is then the taxon listing, rather than an individual curtain.

Lubbly, jubbly!  Simples...

### XML feedback from RomanCart ###

ROMANCARTXML to '/cart/completed':

1. Add route for 'www.bespokesilkcurtains.com/cart/completed' in 'config/routes.rb' since this is not a standard
   Spree URL so that RomanCart can send the XML file on completion of the payment.
2. Parse XML with Nokogiri in '/app/controllers/spree/orders_controller.rb::completed'.
3. Populate @order with name, address, email and payment status from RomanCart.

