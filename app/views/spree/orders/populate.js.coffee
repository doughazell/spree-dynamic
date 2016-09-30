<%
=begin %>
---------------------------------------------- COMMENTS ---------------------------------------------------
  jQuery syntax:
    ($ '#price-text').text("<%= __FILE__ %>")
  
  Also coffeescript uses indentation for blocks
--------------------------------------------- END: COMMENTS ------------------------------------------------
<%
=end %>


# 17/10/13 DH: This just populates the "Cart: ..." link on the Products Show page via AJAX.
#              The cart itself is a DB table on the server which then is used by Orders Edit
($ '#link-to-cart').html("<%= j(link_to_cart) %>")

<%# debugger %>

<% if flash[:error] %>

($ '#page-link-to-cart').html("<p style='color:red;font-size: 1.5em;'><%= flash[:error] %></p>")
<% flash.clear %>

<%
=begin %>
---------------------------------------------- COMMENTS ---------------------------------------------------
<%# flash_messages %>
<% flash.each do |msg_type, text| %>
($ '.flash.<$= msg_type %>').text("<%= text %>")
<% end %>
--------------------------------------------- END: COMMENTS ------------------------------------------------
<%
=end %>


<% else %>

($ '#page-link-to-cart').html("<%= j(link_to_cart) %>")

<% end %>