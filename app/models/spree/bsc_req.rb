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
    
  end
end