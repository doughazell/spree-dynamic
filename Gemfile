source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '4.0.2'
#gem 'rails', '~> 4.0.6'
#gem 'rails', '~> 4.1.2'
#gem 'rails', '~> 4.1.8'
gem 'rails', '~> 4.2.0'

gem 'pg'

# Use SCSS for stylesheets
# 24/9/16 DH: Upgrading to Spree-3.0.10 needed 'sass (>= 3.3.0)' and 'sass-rails (~> 4.0.0)' needed 'sass (~> 3.2.2)'
#             $ bundle update spree
#             $ bundle exec rake railties:install:migrations
#             $ rake db:migrate
#gem 'sass-rails', '~> 4.0.0'
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta'
  gem 'capybara', '2.2.0'
  
  # 23/7/14 DH: 'capybara-webkit' depends on 'capybara (< 2.4.0, >= 2.0.2)' (but 'accept_alert' in '2.4.0'...hmmm!)
  #gem 'capybara', '2.4.0'
  
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  
  # 27/5/14 DH: Getting spree 'frontend/spec/features/order_spec.rb' working locally
  # 6/7/14 DH: gem 'ffaker' is included from 'spree_core' so not need to be included here to be "require"d in 
  #            'lib/spree/testing_support/factories.rb'
  gem 'factory_girl'
  
  #gem 'debugger', group: [:development, :test]
  gem 'byebug'
  
  # 22/4/14 DH: Attempting to visualise Spree DB
  gem 'railroady'
end



# 18/12/13 DH: https://github.com/spree/spree/issues/4101 - "undefined method `content_tag' for Spree:Module" error
#gem 'spree', '2.1.3'
#gem 'spree', github: 'spree/spree', branch: '2-2-stable'
#gem 'spree', :github => 'spree/spree', :branch => '2-3-stable'
#gem 'spree', github: 'spree/spree', branch: '2-4-stable'
gem 'spree', github: 'spree/spree', branch: '3-0-stable'

gem 'spree_gateway', :git => 'https://github.com/spree/spree_gateway.git', :branch => '3-0-stable'
gem 'spree_auth_devise', :git => 'https://github.com/spree/spree_auth_devise.git', :branch => '3-0-stable'

gem 'rmagick', '2.13.2', :require => false
