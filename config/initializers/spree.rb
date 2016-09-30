# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to override the default site name.
  # config.site_name = "Spree Demo Site"
  #config.site_name = "Bespoke Silk Curtains Company"
  config.logo = "store/BSCCoy-logo.jpg"
  config.products_per_page = 200
  
end

Spree.user_class = "Spree::User"
