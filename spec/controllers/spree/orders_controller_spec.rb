require 'spec_helper'

describe Spree::OrdersController do
  user = Spree::User.find_by_email("spree@example.com")
  #let(:user) { user }
  
  order = Spree::Order.find_by_user_id(user.id)
  #let(:order) { order }
  
  let(:the_description) do |example|
    example.description
  end
  
  itemNum = 0
  itemTotal = order.line_items.count
  puts
  order.line_items.each do |item|
    itemNum += 1
    puts "Order: #{order.number} - (#{itemNum}/#{itemTotal} items) #{Spree::Variant.find_by_id(item.variant_id).name}, bsc_req_id: #{item.bsc_req_id}"
  end

  before do
    # "Using `any_instance` from rspec-mocks' ... is deprecated. Use the new `:expect` syntax ..."
    #Spree::OrdersController.any_instance.stub(:try_spree_current_user => user)
    allow_any_instance_of(Spree::OrdersController).to receive(:try_spree_current_user) { user }
    #allow_any_instance_of(Object).to receive(:foo).and_return(:return_value)
    
    #user = Spree::OrdersController.new.try_spree_current_user
    #order = Spree::Order.find_by_user_id(user.id)
  end

  context "POST #completed" do

    it "receives the ROMANCARTXML parameter" do
      #romancartxml = IO.read("romancart-delivery-address.xml")
      romancartxml = File.read("romancart-delivery-address.xml")
            
      #post :completed, :ROMANCARTXML => @romancartxml, :content_type => 'application/xml'
      post :completed, :ROMANCARTXML => romancartxml
      
      # "Using `should` from rspec-expectations' old ... is deprecated. Use the new `:expect` syntax..."
      #controller.params[:ROMANCARTXML].should include "<storeid>"
      expect(controller.params[:ROMANCARTXML]).to include "<storeid>"
      
      #expect(controller.params[:ROMANCARTXML]).to have_content "<storeid>"
    end


    it "rejects ROMANCARTXML with the wrong store id" do
      romancartxml = File.read(File.expand_path("../../../fixtures/romancart-wrong-storeid.xml", __FILE__))
      
      # Regex as arg since not know number of orders with specified price
      #Rails.logger.should_receive(:info).with(/orders in 'cart' state with a price of/)

      #Rails.logger.should_receive(:warn).with("No matching order found for ROMANCARTXML")
      
      # "Using `should_receive` from rspec-mocks' ... is deprecated. Use the new `:expect` syntax ..."
      #Rails.logger.should_receive(:tagged).with("BSC:WRONG-STOREID")
      expect(Rails.logger).to receive(:tagged).with("BSC:WRONG-STOREID")
      
      #Spree::OrdersController.logger.should_receive(:tagged).with("BSC:ERROR")
      #Spree::OrdersController.logger.should_receive(:tagged).with("BSC:WRONG-STOREID")

      post :completed, :ROMANCARTXML => romancartxml

    end
    
    it "rejects ROMANCARTXML with the wrong number of items" do
      puts "\nLoading ROMANCARTXML with 2 items in \"#{the_description}\"."
      romancartxml = File.read(File.expand_path("../../../fixtures/romancart-2-items.xml", __FILE__))
      
      expect(Rails.logger).to receive(:tagged).with("BSC:INCORRECT-ITEM-NUMBER")
      
      post :completed, :ROMANCARTXML => romancartxml

    end
    
    it "rejects ROMANCARTXML with the wrong item" do
      romancartxml = File.read(File.expand_path("../../../fixtures/romancart-1-item.xml", __FILE__))
      
      expect(Rails.logger).to receive(:tagged).with("BSC:INCORRECT-ITEM")
      
      post :completed, :ROMANCARTXML => romancartxml

    end

    it "accepts valid ROMANCARTXML and completes order from cheque payment" do
      romancartxml = File.read(File.expand_path("../../../fixtures/romancart-burgundy-bsc_req_id-5.xml", __FILE__))
      
      post :completed, :ROMANCARTXML => romancartxml

      # 23/5/14 DH: Order should have state "complete" and payment state "paid"
      order.reload
      expect(order.state).to eq("complete")
      expect(order.payment_state).to eq("paid")
      # 24/5/14 DH: Since 'config.use_transactional_fixtures = true' is set in 'spec_helper.rb'
      #             then the DB state change will be rolled back at test completion...sweet!
    end

    it "rejects ROMANCARTXML with the wrong price" do
      romancartxml = File.read(File.expand_path("../../../fixtures/romancart-burgundy-wrong-price.xml", __FILE__))
      
      expect(Rails.logger).to receive(:tagged).with("BSC:WRONG-PRICE")
      
      post :completed, :ROMANCARTXML => romancartxml
      
      #expect(Rails.logger).to receive(:tagged).with("BSC:WRONG-PRICE")

    end

  end # END: 'context "POST #completed"'

=begin
  # From 'github.com/rspec/rspec-rails' Controller Specs
  describe "GET #index" do
    it "loads all of the posts into @posts" do
      post1, post2 = Post.create!, Post.create!
      get :index

      expect(assigns(:posts)).to match_array([post1, post2])
    end
  end
=end

end
