source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '4.0.2'
#gem 'rails', '~> 4.0.6'
#gem 'rails', '~> 4.1.2'
#gem 'rails', '~> 4.1.8'
gem 'rails', '~> 4.2.0'
# 24/9/20 DH: Checkout the date on Upgrade to Spree-3.0.10...:)
#             Getting around Bundler 2 default issue
#  $ gem install bundler -v 1.17.3 ; bundle _1.17.3_ install

gem 'pg', '0.18.1'

# Use SCSS for stylesheets
# 24/9/16 DH: Upgrading to Spree-3.0.10 needed 'sass (>= 3.3.0)' and 'sass-rails (~> 4.0.0)' needed 'sass (~> 3.2.2)'
#             $ bundle update spree
#             $ bundle exec rake railties:install:migrations
#             $ rake db:migrate
#gem 'sass-rails', '~> 4.0.0'

# 25/10/20 DH: FAILED attempt to solve: "Failure/Error: FactoryGirl.create(:payment_method)...undefined method `environment='"
#              'sass-rails' >= 6 uses 'sassc-rails'
gem 'sass-rails', '5.0.6'

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
  #gem 'rspec-rails', '~> 3.0.0.beta'
  #gem 'capybara', '2.2.0'
  
  # 23/7/14 DH: 'capybara-webkit' depends on 'capybara (< 2.4.0, >= 2.0.2)' (but 'accept_alert' in '2.4.0'...hmmm!)
  #gem 'capybara', '2.4.0'

  # 25/9/20 DH: Getting RSpec/Capybara working on on High Sierra
  gem 'rspec-rails'
  gem 'capybara'
  
  gem 'selenium-webdriver'
  #gem 'capybara-webkit'

  # 26/9/20 DH: qt@5.5/5.5.1_1/lib/QtCore.framework/Headers/qglobal.h:39:12: fatal error: 'cstddef' file not found
  #             capybara-webkit (= 1.15.1) was resolved to 1.15.1, which depends on
  #               capybara (>= 2.3, < 4.0) was resolved to 3.33.0, which depends on
  #               Ruby (>= 2.5.0)
  gem 'capybara-webkit', '1.15.1'
  
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

# 16/10/20 DH: Getting devise error with Ruby-2.5 on login (solved by deleting '{...}' end of line in
#              'devise-3.5.10/app/controllers/devise/sessions_controller.rb:5')
#gem 'spree_auth_devise', :git => 'https://github.com/spree/spree_auth_devise.git', :branch => '3-0-stable'
gem 'spree_auth_devise'

gem 'rmagick', '2.13.2', :require => false

# 25/9/20 DH: activesupport-4.2.11.3/.../duplicable.rb:111:undefined method `new' for BigDecimal:Class
gem 'bigdecimal', '1.4.2'

# 25/9/20 DH: https://github.com/rails/sprockets/blob/070fc01947c111d35bb4c836e9bb71962a8e0595/UPGRADING.md#manifestjs
#             Regress from v4 via: $ bundle update sprockets
gem 'sprockets', '3.7.0'

# 25/9/20 DH: 'undefined method `last_comment' for #<Rake::Application' on '$ bundle exec rake db:create'
gem 'rake', '11.3.0'

# 26/9/20 DH: Now trying with Ruby-2.4 (which is oldest version that will compile on High Sierra due to SSL 1.1)
#             json-1.8.3/ext/json/ext/generator.c:861:25: error: use of undeclared identifier 'rb_cFixnum'
gem 'json', '1.8.6'

