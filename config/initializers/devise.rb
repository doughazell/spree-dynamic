Devise.secret_key = SecureRandom.hex(50).inspect
#puts "Devise.secret_key.length" + Devise.secret_key.length.to_s

# 9/5/14 DH: Getting 'spree_auth_devise' to work with 'rake test:integration'
Devise.setup do |config|
  #config.force = true
  #config.use_default_scope = true
  #config.params_authenticatable = true
  #config.authentication_keys = [ :login ]
end