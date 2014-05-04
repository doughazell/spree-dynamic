module Spree
  class BscReq < ActiveRecord::Base
    has_one :line_item, class_name: "Spree::LineItem"
    
    validates_presence_of :width, :drop, :lining, :heading
  
    def self.createBscReqHash(bsc_spec)
      reqs = Hash.new
      bsc_spec.split(',').each do |req|
        category, value = req.split('=')
        reqs[category] = value
      end
      reqs
    end
    
    # 3/5/14 DH: First idea to prevent a row being added to 'spree_bsc_reqs' with a missing value.
    #            Solved by adding 'not null' to each column in the DB with the 'AddNotNullToSpreeBscReq' migration.
=begin
    def valid?(context = nil)
      puts "#{line_item.bsc_req} : #{line_item.bsc_req.inspect}"
      return false if line_item.bsc_req.width.nil?
      return false if line_item.bsc_req.drop.nil?
      return false if line_item.bsc_req.lining.nil?
      return false if line_item.bsc_req.heading.nil?
      true
    end
=end
  end
end