require 'spec_helper'

describe Spree::OrderPopulator do

  context "normal Spree objects" do
    let(:order) { Spree::Order.create }
    subject { Spree::OrderPopulator.new(order, "GBP") }
        
    it "should give an error message on adding a 'hacked' price" do |example|
      specStr = "width=144,drop=69,lining=cotton,heading=pencil pleat"
      subject.populate(:products => { 8 => 33 }, :quantity => 1, :price => "53.40", :spec => specStr )

      expect(subject).not_to be_valid

      message = "The dynamic price is incorrect"
      expect(subject.errors.full_messages.join).to eq(message)
    end
    
    context "uses temp order found from DB" do
      before do
        temp_order = order.class.find_by_number("R043377643")
        # "let and subject declarations are not intended to be called in a before(:all) hook, as they exist 
        #  to define state that is reset between each example, while before(:all) exists to define state that 
        #  is shared across examples in an example group."
        @line_item = temp_order.line_items.first
      end
      
      it "accepts a browser prior added order" do

        bscDynamicPrice = @line_item.price
        bscSpec         = @line_item.bsc_spec
        product_id      = @line_item.product.id
        variant_id      = @line_item.variant.id
        
        subject.populate("products" => { product_id => variant_id }, "quantity" => 1, "price" => bscDynamicPrice, "spec" => bscSpec )
                  
        expect(subject).to be_valid

      end
    end

  end # END: context "normal Spree objects"

  context "with stubbed out find_variant" do
    let(:order) { double('Order') }
    subject { Spree::OrderPopulator.new(order, "GBP") }

    let(:variant) { double('Variant', :name => "LIME", :options_text => "Heading: Pencil Pleat") }
    #let(:variant) { Spree::Variant.find_by_sku("845-0167-1") }
    
    before do
      # 24/7/14 DH: Old syntax for double (mock) messages
      #Spree::Variant.stub(:find).and_return(variant)
      allow(Spree::Variant).to receive_messages(:find => variant)
      
      #order.should_receive(:contents).at_least(:once).and_return(Spree::OrderContents.new(self))
      expect(order).to receive(:contents).at_least(:once).and_return(Spree::OrderContents.new(self))
    end

    context "with products parameters" do
      it "can take a list of products and add them to the order" do
        #order.contents.should_receive(:add).with(variant, 1, subject.currency).and_return double.as_null_object
        expect(order.contents).to receive(:add).with(variant, 1, subject.currency).and_return double.as_null_object
        
        subject.populate(:products => { 1 => 2 }, :quantity => 1)
      end

      context "variant out of stock" do
        before do
          #line_item = double("LineItem", valid?: false)
          #line_item = double("LineItem", :valid? => false)
          
          line_item = double("LineItem")
          
          #line_item.stub_chain(:errors, messages: { quantity: ["error message"] })
          allow(line_item).to receive_message_chain(:errors, :messages).and_return(:quantity => ["error message"])
          
          #order.contents.stub(add: line_item)
          #order.contents.stub(remove: line_item)
          allow(order.contents).to receive(:add).and_return(line_item)
          allow(order.contents).to receive(:remove).and_return(line_item)
          
        end

        it "adds an error when trying to populate" do
          specStr = "width=144,drop=69,lining=cotton,heading=pencil pleat"
          
          #subject.populate("products" => { 8 => 33 }, "quantity" => 1, "price" => "53.40", "spec" => specStr )
          
          # 24/7/14 DH: With an Order Double you need method symbols rather than hash key strings sent from 
          #             'spree/orders#populate'
          subject.populate(:products => { 8 => 33 }, :quantity => 1, :price => "53.40", :spec => specStr )

          # 24/7/14 DH: ActiveRecord Validations Guide states, "After Active Record has performed validations, any errors found 
          #             can be accessed through the 'errors.messages' instance method, which returns a collection of errors. 
          #             By definition, an object is valid if this collection is empty after running validations."
          #
          #             Therefore, assigning the 'line_item' mock 'errors.messages' chain above causes 'valid?' to return 'false'

          expect(subject).not_to be_valid
          expect(subject.errors.full_messages.join).to eql "error message"
        end
        
      end # END: context "variant out of stock"

    end # END: context "with products parameters"

    context "with variant parameters" do
      it "can take a list of variants with quantites and add them to the order" do
        #order.contents.should_receive(:add).with(variant, 5, subject.currency).and_return double.as_null_object
        expect(order.contents).to receive(:add).with(variant, 5, subject.currency).and_return double.as_null_object
        
        subject.populate(:variants => { 2 => 5 })
      end
    end
    
  end # END: context "with stubbed out find_variant"
end
