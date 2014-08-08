# 8/7/14 DH: This is mostly the Spree Frontend 'spec/features/order_spec.rb' with the user an actual Spree
#            user in the DB (rather than created by FactoryGirl) AND accessing a valid order 
#            (rather than just using the 'OrderWalkthrough' in 'lib/spree/testing_support/order_walkthrough.rb'
#             WHICH IS A FORM OF 'STUB' SINCE JUST REPLICATES THE ORDER CODE FOR THE FEATURES BEING TESTED)
require 'spec_helper'

describe 'orders' do

  # 17/5/14 DH: Using FactoryGirl + Spree Order State Machine
  #let(:order) { OrderWalkthrough.up_to(:complete) }
  #let(:order) { Spree::Order.create }
  #let(:order) { Spree::Order.find_by_number("R043377643") }
  
  # 17/5/14 DH: 'FactoryGirl.create'
  #puts "\nCalling create(:user) in #{__FILE__}"
  #let(:user) { create(:user) }
  
  # 29/5/14 DH: If the user is created with 'lib/spree/testing_support/factories/user_factory.rb' then no valid
  #             devise session created so that 'visit spree.order_path(order)' returns a blank page
  #let(:user) { Spree::User.find_by_email("spree@example.com") }

  before do
    #order.update_attribute(:user_id, user.id)
    #order.shipments.destroy_all
    
    # 17/5/14 DH: This is the equivalent of doing the login below
    #Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)

=begin    
    visit "/login"
    fill_in "Email", with: "spree@example.com"
    fill_in "Password", with: "spree123"
    click_button "Login"

    expect(page).to have_text("Logged in successfully")
=end

  end # END: before
  
  #around do |example|
  #  example.run
  #end

  it "can visit a FactoryGirl order" do |example|
    # Add 'heredoc' character to start of test output
    puts "\n\n--TEST-- <<."
    
    # Regression test for current_user call on orders/show
    order = OrderWalkthrough.up_to(:complete)
    user = create(:user)
    Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)

    puts "#{self.class.description} - \"#{example.description}\": '#{spree.order_path(order)}' for '#{user.email}'"
    
    #lambda { visit spree.order_path(order) }.should_not raise_error
    visit spree.order_path(order)
    expect(current_path).to eq(spree.order_path(order))
    
  end

  it "can visit a valid order for the current user" do |example|
    puts "\n\n--TEST-- <<."
    
    # 8/7/14 DH: My additions to play with features testing
    order_id = "R043377643"
    user = Spree::User.find_by_email("spree@example.com")
    Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)
    
    puts "#{self.class.description} - \"#{example.description}\": '/orders/#{order_id}' for '#{user.email}'"
    visit "/orders/#{order_id}"
    expect(page).to have_content "Order ##{order_id}"

  end

  it "can NOT visit a valid order for the WRONG user" do |example|
    puts "\n\n--TEST-- <<."
    
    # 8/7/14 DH: My additions to play with features testing
    order_id = "R043377643"
    user = create(:user)
    Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)
    
    puts "#{self.class.description} - \"#{example.description}\": '/orders/#{order_id}' for '#{user.email}'"
    
    visit "/orders/#{order_id}"
    expect(page).to_not have_content "Order ##{order_id}"

  end

  
  it "can NOT visit an order with the WRONG ID" do |example|
    puts "\n\n--TEST-- <<."
    
    order_id = "R043377643-X"
    user = Spree::User.find_by_email("spree@example.com")
    Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)    
    
    puts "#{self.class.description} - \"#{example.description}\": '/orders/#{order_id}' for '#{user.email}'"
    visit "/orders/#{order_id}"
    expect(page).to have_content "The page you were looking for doesn't exist."

  end
  
end
