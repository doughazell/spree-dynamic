require 'spec_helper'

#describe Spree::OrderContents do
describe Spree::OrderContents, :type => :model do
  let(:order) { Spree::Order.create }
  
  subject { described_class.new(order) }

  context "#add" do
    #let(:variant) { create(:variant) }
    #let(:variant) { double('Variant', :name => "T-Shirt", :options_text => "Size: M") }
    let(:variant) { Spree::Variant.find_by_sku("745-0299-1") }

    # ================= [BSC spec Unit/Functional Testing] =============

    it "should accept a complete BSC req set" do
      subject.bscSpec = "width=14,drop=7,lining=cotton,heading=pencil pleat"
      line_item = subject.add(variant)
      
      reqs = Spree::BscReq.createBscReqHash(line_item.bsc_spec)
      
      expect { line_item.create_bsc_req(reqs) }.to_not raise_error
      
      expect(line_item.bsc_req).to be_valid
    end

    # 3/5/14 DH: Starting BDD by creating a test for an aspect that doesn't work as I want
    # 4/5/14 DH: This works by testing the ActiveRecord association 'create_bsc_req' method with an incomplete record hash

    it "should reject an incomplete BSC req set but not raise error" do
      line_item = subject.add(variant)
      line_item.bsc_spec = "width=14,drop=7,lining=cotton,heading=pencil pleat"
      
      reqs = Spree::BscReq.createBscReqHash(line_item.bsc_spec)

      reqs.delete("width")
      
      # 16/7/14 DH: "PG::NotNullViolation: ERROR:  null value in column "width" violates not-null constraint" due to 'AddNotNullToSpreeBscReq'
      #             if not have 'validates_presence_of :width, :drop, :lining, :heading' in 'Spree::BscReq'
      expect { line_item.create_bsc_req(reqs) }.to_not raise_error
      
      # 16/7/14 DH: "Does the same as create_association above, but raises ActiveRecord::RecordInvalid if the record is invalid."
      #expect { line_item.create_bsc_req!(reqs) }.to raise_error

      # 18/7/14 DH: Old 'should' syntax
      #line_item.bsc_req.should_not be_valid
      expect(line_item.bsc_req).to_not be_valid
    end
    
    it "should not update line item if one exists due to BSC spec per line item" do
      subject.add(variant, 1)
      line_item = subject.add(variant, 1)

      # 18/7/14 DH: Old 'should' syntax
      #line_item.quantity.should == 1
      #order.line_items.size.should == 1
      expect line_item.quantity == 1
      expect order.line_items.size == 1

    end

    # ================= [BSC spec Integration Testing] =================

    # 4/5/14 DH: This simulates 'orders#populate' being called with an incomplete BSC Spec string
    # 4/5/14 DH: It is a more abstract level than the validity checking done in 'Spree::OrderContents#add_to_line_item'
    #            ie "should reject an incomplete BSC req set but not raise error"

    it "should give an error message on adding an incomplete BSC req set" do
      subject.bscDynamicPrice = 69
      #subject.bscSpec = "width=14,drop=7,lining=cotton,heading=pencil pleat"
      subject.bscSpec =           "drop=7,lining=cotton,heading=pencil pleat"

      line_item = subject.add(variant)
      expect line_item.bsc_req.id.nil?
      
      message = "The BSC requirement set is missing a value"
      expect(line_item.bsc_req.msgs.join).to eq(message)
    end

    # 17/7/14 DH: TDD to prevent price hacking
    it "should give an error message on adding a 'hacked' price" do |example|
      subject.bscDynamicPrice = 53.40
      subject.bscSpec = "width=144,drop=69,lining=cotton,heading=pencil pleat"
      
      line_item = subject.add(variant)
      expect line_item.bsc_req.id.nil?
      
      message = "The dynamic price is incorrect"
      expect(line_item.bsc_req.msgs.join).to eq(message)
    end

=begin
    it "should accept a valid dynamic price from an order added via the web" do |example|
      order = Spree::Order.find_by_number("R043377643")
      line_item = order.line_items.first

      subject.bscDynamicPrice = line_item.price
      subject.bscSpec         = line_item.bsc_spec

      expect { subject.add(line_item.variant) }.to_not raise_error
    end
=end

  end

end
