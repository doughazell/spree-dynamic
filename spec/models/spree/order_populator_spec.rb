require 'spec_helper'

describe Spree::OrderPopulator do
  let(:order) { double('Order') }
  subject { Spree::OrderPopulator.new(order, "GBP") }

  context "with stubbed out find_variant" do
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
          line_item = double("LineItem", valid?: false)
          
          #line_item.stub_chain(:errors, messages: { quantity: ["error message"] })
          allow(line_item).to receive_message_chain(:errors, :messages).and_return(:quantity => ["error message"])
          
          #order.contents.stub(add: line_item)
          #order.contents.stub(remove: line_item)
          allow(order.contents).to receive(:add).and_return(line_item)
          allow(order.contents).to receive(:remove).and_return(line_item)
          
        end

        it "adds an error when trying to populate" do
          specStr = "width=144,drop=69,lining=cotton,heading=pencil pleat"
          subject.populate(:products => { 8 => 33 }, :quantity => 1, :price => "53.40", :spec => specStr )
          
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
  end
end
