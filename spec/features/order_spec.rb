# 16/7/15 DH: Refactor of earlier order spec for bare-bones DB on Spree-3.0
require 'spec_helper'

RSpec.configure do |config|
  # 29/5/14 DH: DB transactions prevent DB permanent row creation (and roll-back after a test)
  config.use_transactional_fixtures = true
end

describe 'orders', :type => :feature do
=begin
  # 17/7/15 DH: Cann't do an OrderWalkthrough here since all the DB state of product, variants, options is not cleared by
  #             just deleting the order, so needs to be done in each test and 'config.use_transactional_fixtures = true'
  #             https://relishapp.com/rspec/rspec-rails/docs/transactions
  before(:all) do
    # 16/7/15 DH: Using FactoryGirl + Spree Order State Machine
    @order = OrderWalkthrough.up_to(:complete)
  end # END: before
  
  after(:all) do
    if @order
      @order.delete
    end
  end # END: after
=end

  it "can visit a FactoryGirl order" do |example|
    puts "\n--- TEST: #{example.description} ---"
    order = OrderWalkthrough.up_to(:complete)
    
    user = Spree::User.find_by_email("spree@example.com")
    
    allow_any_instance_of(Spree::OrdersController).to receive_messages(:try_spree_current_user => user)

    puts "\n#{self.class.description} - \"#{example.description}\": '#{spree.order_path(order)}' for '#{user.email}'"
    
    visit spree.order_path(order)
    expect(current_path).to eq(spree.order_path(order))
  end

  it "gets redirected to login when visiting an order" do |example|  
    puts "\n--- TEST: #{example.description} ---"
    order = OrderWalkthrough.up_to(:complete)

    puts "\n#{self.class.description} - \"#{example.description}\": '#{spree.order_path(order)}'"
    
    visit spree.order_path(order)
    
    # 16/7/15 DH: 'page.current_url' adds 'http://www.example.com' or whatever domain is specified by ...
    #expect(page.current_url).to eq("/login")
    expect(current_path).to eq("/login")
    
  end

  it "gets unauthorized for unknown user visiting order" do |example|
    puts "\n--- TEST: #{example.description} ---"
    order = OrderWalkthrough.up_to(:complete)
    user = create(:user)
    
    #order.update_attribute(:user_id, user.id)
    #order.shipments.destroy_all
    allow_any_instance_of(Spree::OrdersController).to receive_messages(:try_spree_current_user => user)
    puts "\n#{self.class.description} - \"#{example.description}\": '#{spree.order_path(order)}' for '#{user.email}'"
    
    expect { visit spree.order_path(order) }.not_to raise_error
    expect(page).to have_content "Authorization Failure"
    expect(current_path).to eq("/unauthorized")
    
    # 16/7/15 DH: This is not appropriate at the Capybara BDD level of testing!
    # Needs ':type => :controller'
    #expect(response).to redirect_to '/unauthorized'

  end

  it "gets redirected to login prior to visiting an order" do |example|  
    puts "\n--- TEST: #{example.description} ---"
    order = OrderWalkthrough.up_to(:complete)

    puts "\n#{self.class.description} - \"#{example.description}\": '#{spree.order_path(order)}'"
    
    visit spree.order_path(order)
    
    expect(current_path).to eq("/login")

    fill_in('spree_user_email', :with => 'spree@example.com')
    fill_in('spree_user_password', :with => 'spree123')
    
    find(:class, 'input.btn').click
    
    expect(current_path).to eq(spree.order_path(order))
    
  end

end
