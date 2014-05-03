module Spree
  class BscReq < ActiveRecord::Base
    has_one :line_item, class_name: "Spree::LineItem"
  
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
    def self.valid?
      #line_item.bsc_req
    end
    
  end
end