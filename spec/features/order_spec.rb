require 'spec_helper'

describe 'orders' do
  # 17/5/14 DH: Using FactoryGirl + Spree Order State Machine
  let(:order) { OrderWalkthrough.up_to(:complete) }
  #let(:order) { Spree::Order.create }
  #let(:order) { Spree::Order.find_by_number("R667240416") }
  
  # 17/5/14 DH: 'FactoryGirl.create'
  #puts "\nCalling create(:user) in #{__FILE__}"
  #let(:user) { create(:user) }
  
  # 29/5/14 DH: If the user is created with 'lib/spree/testing_support/factories/user_factory.rb' then no valid
  #             devise session created so that 'visit spree.order_path(order)' returns a blank page
  let(:user) { Spree::User.find_by_email("spree@example.com") }

  before do
    #order.update_attribute(:user_id, user.id)
    #order.shipments.destroy_all
    
    # 17/5/14 DH: This is the equivalent of doing the login below
    Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)

=begin    
    visit "/login"
    fill_in "Email", with: "spree@example.com"
    fill_in "Password", with: "spree123"
    click_button "Login"

    expect(page).to have_text("Logged in successfully")
=end

  end

  it "can visit an order" do
    # Regression test for current_user call on orders/show
    puts "\nspree.order_path(#{order}):"
    puts spree.order_path(order)
    
    lambda { visit spree.order_path(order) }.should_not raise_error
    
    visit spree.order_path(order)
    #expect(page).to have_content "Order #R667240416"
    
    visit "/orders/R66724041X"
    expect(page).to have_content "The page you were looking for doesn't exist."

  end

  it "should display line item price" do
    # Regression test for #2772
    line_item = order.line_items.first
    puts "\nCalling create(:shipment) in #{__FILE__}"
    line_item.target_shipment = create(:shipment)
    line_item.price = 19.00
    line_item.save!

    puts "\n#{order.email}"
    puts spree.order_path(order) + "\n\n"
    
    visit spree.order_path(order)

    #puts page.body

    # Tests view spree/shared/_order_details
    
    # [data-hook="order_item_price"]
    within 'td.price' do
      page.should have_content "19.00"
    end
  end
  
  it "should have credit card info if paid with credit card" do
    create(:payment, :order => order)
    visit spree.order_path(order)
    within '.payment-info' do
      page.should have_content "Ending in 1111"
    end
  end
  
  it "should have payment method name visible if not paid with credit card" do
    create(:check_payment, :order => order)
    visit spree.order_path(order)
    within '.payment-info' do
      page.should have_content "Check"
    end
  end

  # Regression test for #2282
  context "can support a credit card with blank information" do
    before do
      credit_card = create(:credit_card)
      credit_card.update_column(:cc_type, '')
      payment = order.payments.first
      payment.source = credit_card
      payment.save!
    end

    specify do
      visit spree.order_path(order)
      within '.payment-info' do
        lambda { find("img") }.should raise_error(Capybara::ElementNotFound)
      end
    end
  end

  it "should return the correct title when displaying a completed order" do
    visit spree.order_path(order)

    within '#order_summary' do
      page.should have_content("#{Spree.t(:order)} #{order.number}")
    end
  end

end
