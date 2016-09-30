# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
#SpreeBSC::Application.config.secret_key_base = '439106a61b3633fb72c83aecbfc9ffd8ced3f936093587007cdfb4bbfb2f0c3c47bd04edada04a453514aef88b8cd4c8f44232c3f0749bae0bdc01c19540ae2b'

#puts "SpreeBSC::Application.config.secret_key_base.length:" + SpreeBSC::Application.config.secret_key_base.length.to_s
#puts "SpreeBSC::Application.config.secret_key_base:" + SpreeBSC::Application.config.secret_key_base.to_s

SpreeDynamic::Application.config.secret_key_base = SecureRandom.hex(64)

#puts "SpreeBSC::Application.config.secret_key_base.length:" + SpreeBSC::Application.config.secret_key_base.length.to_s
#puts "SpreeBSC::Application.config.secret_key_base:" + SpreeBSC::Application.config.secret_key_base.to_s
