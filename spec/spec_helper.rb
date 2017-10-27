# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'ffaker'
require 'rspec/autorun'
require 'capybara/rails'

# 27/5/14 DH: Atempting to get Spree FactoryGirl++ working
#require 'spree/testing_support/authorization_helpers'
#require 'spree/testing_support/capybara_ext'
require 'spree/testing_support/factories'
#require 'spree/testing_support/preferences'
#require 'spree/testing_support/controller_requests'
#require 'spree/testing_support/flash'
#require 'spree/testing_support/url_helpers'
require 'spree/testing_support/order_walkthrough'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  
  # 29/5/14 DH: DB transactions prevent DB permanent row creation (and roll-back after a test)
  #config.use_transactional_fixtures = true
  
  # 29/9/16 DH: Needed for prev created orders necessary for 'context "POST #completed"' in 'orders_controller_spec.rb'
  config.use_transactional_fixtures = false
  # 14/10/16 DH: See 'RSpec.configure' block in '~/spec/features/order_spec.rb' for local override

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  #config.infer_base_class_for_anonymous_controllers = false

  # 14/7/15 DH: http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/ :
  #             "rspec-rails automatically adds metadata to specs based on their location on the filesystem.
  #              In RSpec 3, this behavior must be explicitly enabled"
  #config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #config.order = "random"
  # 20/7/15 DH: Spree::OrdersController needs to have the comletion order at the end which is at the end of the file.
  config.order = "default"
  # 20/7/15 DH: Stop after first test fail
  config.fail_fast = true
  
  # 27/5/14 DH: Atempting to get Spree FactoryGirl++ working
  config.include FactoryGirl::Syntax::Methods
  
  # 22/7/14 DH: Adding helper methods in files under 'spec/support'
  config.include Helpers
end
