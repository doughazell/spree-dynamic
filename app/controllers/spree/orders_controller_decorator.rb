Spree::OrdersController.class_eval do
  respond_to :js
  # 28/12/13 DH: This looked like it would work but didn't so 'params.permit(:bsc_spec)' was added to 'populate'
  #Spree::PermittedAttributes.line_item_attributes << :bsc_spec
end