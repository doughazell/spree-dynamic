module Spree
  module DynamicHelper
  
    def lineItemToOrderItem(line_item)
      spec = line_item.bsc_spec
      silk_name = Spree::Variant.find_by_id(line_item.variant_id).name
      silk_sku  = Spree::Variant.find_by_id(line_item.variant_id).sku

      order_item = "#{silk_name}-#{silk_sku}(#{spec})"

    end
    
    def addDynamicPriceReq(line_item)

      catch(:sample) {
        # 29/12/13 DH: If a dynamic price was returned from the Products Show then use it to populate the line item
        
          
        # 29/4/14 DH: Checkout the date diff from the old spec population doode!
        #             Anyway, now populating a separate table rather than just storing an unparsed string
        #             The string is used for the RomanCart integration until the order has "Status Complete",
        #             otherwise it would lead to "data redundancy" and risk "data anomalies"!
        
        #line_item.create_bsc_req!(width: 20, drop: 20, lining: "You", heading: "Beauty")
#debugger          
        if line_item.bsc_spec
          begin
            line_item.create_bsc_req(Spree::BscReq.createBscReqHash(line_item.bsc_spec))
          rescue ActiveRecord::UnknownAttributeError # To catch the default "spec"=>"N/A" for samples
            if line_item.bsc_spec.eql?("N/A")
              throw :sample # Which is caught above to allow adding a sample without later inevitable errors
            else
              raise "Unknown BSC spec of: #{line_item.bsc_spec}"
            end
          end
#debugger 
          if line_item.bsc_req.invalid?
            #raise "The BSC requirement set is missing a value"
            
            message = "The BSC requirement set is missing a value"
            # 18/6/15 DH: With Spree-2.3 to Spree-2.4 upgrade 'line_item.errors' is not used any more
            #         (prob because it gets cleared during the validations after an 'ActiveRecord.save')
            #         Likewise with 'bsc_req.errors' so now using a separate array in 'bsc_req' for extra messages.
            #line_item.bsc_req.errors.add(:base,message)
            
            line_item.bsc_req.msgs = [message]
            
            Rails.logger.error "\n*** #{message} ***\n\n"
            
            line_item.bsc_req_id = -1 # ie Error
            return line_item
          end

          # 22/7/14 DH: Adding in mechanism to simulate a "hacked" dynamic price in RSpec features test
          if ENV['RAILS_ENV'] == 'test' && line_item.bsc_req.respond_to?(:price_alteration)
            line_item.price += line_item.bsc_req.price_alteration
          end
          
          # 17/7/14 DH: Now check that the price is valid for the spec and that we haven't been hacked!
          
          # 17/7/14 DH: Need to save the line item to be able to access it via the Active Record association 
          #             (via the inverse of the FK entry in 'spree_line_items')
          #
          # 30/4/15 DH: The variant needs to be in stock or back-orderable to prevent this being rolled-back!
          line_item.save
                    
          if line_item.bsc_req.dynamic_price_invalid?
            #raise "The dynamic price is incorrect"
           
            message = "The dynamic price is incorrect"
            # 18/6/15 DH: With Spree-2.3 to Spree-2.4 upgrade 'line_item.errors' is not used any more
            #         (prob because it gets cleared during the validations after an 'ActiveRecord.save')
            #         Likewise with 'bsc_req.errors' so now using a separate array in 'bsc_req' for extra messages.
            #line_item.bsc_req.errors.add(:base,message)
            line_item.bsc_req.msgs = [message]
            
            Rails.logger.error "\n*** #{message} ***\n\n"
            
            #line_item.bsc_req_id = -1 # ie Error
            return line_item
          end

=begin
          reqs = Hash.new
          line_item.bsc_spec.split(',').each do |req|
            category, value = req.split('=')
            reqs[category] = value
          end
          line_item.create_bsc_req!(width: reqs["width"], drop: reqs["drop"], lining: reqs["lining"], heading: reqs["heading"])
=end
        end # END: 'if line_item.bsc_spec'
      
        
      } # END: 'catch(:sample)'

    end # END: addDynamicPriceSpec

  end # END: DynamicHelper
end # END: module Spree