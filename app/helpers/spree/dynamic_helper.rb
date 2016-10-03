module Spree
  module DynamicHelper
  
    # -----------------------------------------------------------------------------------
    # 13/7/15 DH: Methods extracted from 'orders_controller.rb' to make upgrading easier

    # 28/12/13 DH: Creating a method to be called by Romancart with 'ROMANCARTXML' to indicate a completed order
    #              '/config/routes.rb':- "match 'cart/completed' => 'spree/orders#completed', :via => :post"        
    def completed_mechanism(posted_xml)

      #@order = current_order
      
      #posted_xml = params[:ROMANCARTXML]

      # Remove XHTML character encoding (hopefully won't need to do this when we receive XML message from RomanCart!)
      xml = posted_xml.sub("<?xml version='1.0' encoding='UTF-8'?>", "")
      
      xml_doc  = Nokogiri::XML(xml)   
#debugger
      total_price = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content
      orders = Spree::Order.where("state = ? AND total = ?", "cart",total_price)
      Rails.logger.info "#{orders.count} orders in 'cart' state with a price of #{total_price}"

# 19/7/15 DH: Now checking 'feedbackValid' so price has to match.
=begin
      if orders.count == 0
        # 5/3/14 DH: Testing ROMANCARTXML feedback locally so price is something...
        orders = Spree::Order.where("state = ? AND total > ?", "cart","0.00")
      end
=end
      if orders
        @order = orders.last
      end
      
      # 6/3/14 DH: Since CSRF checking is removed for ROMANCARTXML feedback then need to check 'storeid' + items match
      if @order and feedbackValid(xml_doc,@order)
        Rails.logger.info "Order number selected: #{@order.number}"
        
        @order.email = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/email").first.content
        
        @order.user_id = xml_doc.xpath("/romancart-transaction-data/orderid").first.content
        
        @order.number = xml_doc.xpath("/romancart-transaction-data/orderid").first.content
        Rails.logger.info "Altering Order number with one assigned by RomanCart"
        #Rails.logger.info "Keeping Spree Order number rather than taking RomanCart one"
        
        #flash[:message] = "Order number taken from current time!"
        #@order.number = Time.now.to_i.to_s
        
        # ----------------------- Billing Address -------------------------------
        @order.bill_address = romancartAddress(xml_doc)
        # ----------------------- Delivery Address ------------------------------        
        #<delivery-address1/>
        if xml_doc.xpath("/romancart-transaction-data/sales-record-fields/delivery-address1").first.content.empty?
          @order.use_billing = true
        else
          @order.ship_address = romancartAddress(xml_doc, "delivery-")
        end
        
        # Spree StateMachine = 1)cart -> 2)address -> 3)delivery -> 4)payment -> 5)confirm -> 6)complete

        # If the order is just for samples then it'll be free so no payment is required
        # (this will go through the Spree cart system rather than via Romancart, hence this method, so this is 
        #  just dev step that could now be removed)
        if @order.item_total == 0
          
          while @order.state != "complete"
            @order.next!
          end
        
        # NOW the normal (non-dev) option...
        else
          
          while @order.state != "payment"
            @order.next!
            Rails.logger.info "Order number '#{@order.number}' is in state:#{@order.state}" 
          end
          
          #if xml_doc.xpath("/romancart-transaction-data/paid-flag").first.content.eql?("True")
          if xml_doc.xpath("/romancart-transaction-data/paid-flag").first.content.eql?("False")
            Rails.logger.info "Testing ROMANCARTXML feedback using cheque payment so '<paid-flag>False</paid-flag>'"

            unless @order.payments.exists?
              # 5/3/14 DH: Previously this worked for 'spree-2.0.4' but the payments system was changed in 'spree-2.1'
              #@order.payments.create!(:amount => @order.total)
              #@order.payments.last.payment_method = Spree::PaymentMethod.find_by_name("RomanCart")
              #@order.payments.last.complete

              # 5/3/14 DH: Taken this from 'spree/2-1-stable/api/app/models/spree/order_decorator.rb'              
              payment = @order.payments.build
              payment.amount = @order.total
              payment.complete
              payment.payment_method = Spree::PaymentMethod.find_by_name("RomanCart")
              payment.save!
	      
              if @order.payments.last.payment_method
                Rails.logger.info "Creating #{@order.payments.last.payment_method.name} payment of #{@order.total}"
              else
                Rails.logger.info "RomanCart payment method not found!"
              end
            end
            
            
            @order.payment_total = @order.total

            # To 6 - Complete
            #@order.payment_state = "paid"
            updater = Spree::OrderUpdater.new(@order)
            updater.update_payment_state
#debugger            
            @order.state = "complete"
            @order.completed_at = Time.now
            @order.save!
            
            # 10/7/14 DH: Copying Spree Checkout to reduce stock quantity
            reduceStock(@order)
            
            Rails.logger.info "Order number '#{@order.number}' is in state:#{@order.state}"
          end # END: if ... "/romancart-transaction-data/paid-flag" is "True" ["False" for dev chq payments!]
        end

      else # 'if @order and feedbackValid(xml_doc,@order)'
      
        # 19/5/14 DH: RSpec Controller testing for '/cart/completed?ROMANCARTXML=' needs to check log output 
        #             amongst Spree error/info sent to 'Rails.logger' for the appropriate tag 
        #             since different tags during the same RSpec test cause problems with test readability!
        
        #logger.tagged("BSC:ERROR") { logger.error "No matching order found for ROMANCARTXML" }
        logger.warn "No matching order found for ROMANCARTXML"

        # "now" "Sets a flash that will not be available to the next action, only to the current."
        flash.now.alert = "No matching order found for ROMANCARTXML"
      end

    end
    
    def reduceStock(order)

      # 11/7/14 DH: Suhhweeeet!  So easy when you know the key, the secret 
      #                       (as the Urban Cookie Collective would tell you)!
      #             The succinctness of this just demonstrates Spree/Ruby on Rails 
      #                      but finding the solution can be the hard part.
      
      order.line_items.each do |item|
        # 10/7/14 DH: Currently only 1 stock location for each variant
        stock_location = item.variant.stock_locations[0]
        
        #stock_location.count_on_hand(item.variant)
        
        #Spree::StockLocation.unstock(variant, quantity, originator = nil)
        stock_location.unstock(item.variant, item.quantity)
      end
      
    end
    
    def feedbackValid(xml_doc, order)
#debugger
      # --- STORE ID ---
      storeid = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/storeid").first.content
      if storeid.to_i != Spree::Config[:romancart_storeid]
        logger.tagged("BSC:WRONG-STOREID") {
          logger.error "Wrong stored id! #{storeid} does not match that configured as #{Spree::Config[:romancart_storeid]}"
        }
        flash.now[:BscWrongStoreid] = "Wrong stored id! #{storeid} does not match that configured as #{Spree::Config[:romancart_storeid]}"
        return false
      end
     
      # --- PRICE ---
      total_price = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content
      if total_price.to_f != order.total.to_f
        logger.tagged("BSC:WRONG-PRICE") {
          logger.error "Wrong price! #{total_price} does not match the order total of #{order.total}"
        }
        flash.now[:BscWrongPrice] = "Wrong price! #{total_price} does not match the order total of #{order.total}"
        return false
      end

      # --- ITEM NUMBER ---
      
      #order_items = xml_doc.xpath("/romancart-transaction-data/order-items")
      #order_items.xpath("order-item").children.each do |child| 
      #  if child.name.eql?("item-name")
      #    puts "#{child.name}: #{child.text}"
      #  end
      #end
      
      rc_items = xml_doc.xpath("/romancart-transaction-data/order-items/order-item/item-name")
      
      #rc_items.children.each do |item|
      #  puts item.text
      #end

      if order.line_items.count != rc_items.count
        logger.tagged("BSC:INCORRECT-ITEM-NUMBER") {
          logger.error "The ROMANCARTXML item number of #{rc_items.count} does not match the order line item number of #{order.line_items.count}"
        }
        flash.now[:BscIncorrectItemnumber] = "The ROMANCARTXML item number of #{rc_items.count} does not match the order line item number of #{order.line_items.count}"
        return false
      end

      # --- ITEMS ---
      # 14/6/14 DH: The item order needs to match which is not necessarily an invalid feedback (so permutation not combination match)
      num = 0
      order.line_items.each do |item|
      
        # 14/6/14 DH: Spree::DynamicHelper method
        order_item = lineItemToOrderItem(item)
        
        rc_item = rc_items[num].text
        if !rc_item.eql?(order_item)
          logger.tagged("BSC:INCORRECT-ITEM") {
            logger.error "'#{order_item}' is not the same as '#{rc_item}'"
          }
          flash.now[:BscIncorrectItem] = "'#{order_item}' is not the same as '#{rc_item}'"
          return false
        end
        
        num += 1
      end

      return true
    end
    
    def romancartAddress(xml_doc, delivery = "")
      rc_xml_country = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}country").first.content
      rc_xml_county  = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}county").first.content
     
      if rc_xml_country.upcase.eql?("UNITED KINGDOM")
        country = Spree::Country.find_by_name("UK")
      end
      if country.nil?
        #country = Spree::Country.create(...)
      end
      state = Spree::State.find_by_name(rc_xml_county.titleize)
      
      order_address = Spree::Address.create!(
        :firstname => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}first-name").first.content,
        :lastname  => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}last-name").first.content,
        :address1  => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}address1").first.content,
        :address2  => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}address2").first.content,
        :city      => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}town").first.content,
        :state     => state,
        :zipcode   => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}postcode").first.content,
        :country   => country,
        :phone     => xml_doc.xpath("/romancart-transaction-data/sales-record-fields/#{delivery}phone").first.content
      )
        
    end
    
    # -----------------------------------------------------------------------------------
      
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

          if line_item.bsc_req.invalid?
            #raise "The BSC requirement set is missing a value"
            
            message = "The BSC requirement set is missing a value"
            # 18/6/15 DH: With Spree-2.3 to Spree-2.4 upgrade 'line_item.errors' is not used any more
            #         (prob because it gets cleared during the validations after an 'ActiveRecord.save')
            #         Likewise with 'bsc_req.errors' so now using a separate array in 'bsc_req' for extra messages.
            #line_item.bsc_req.errors.add(:base,message)
            
            line_item.bsc_req.msgs = [message]
            
            Rails.logger.error "\n*** #{message} ***\n\n"

            #line_item.bsc_req_id = -1 # ie Error
            return line_item
          end

          # 22/7/14 DH: Adding in mechanism to simulate a "hacked" dynamic price in RSpec features test
          if (ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'development') && line_item.bsc_req.respond_to?(:price_alteration)
            line_item.price += line_item.bsc_req.price_alteration
          end
          
          # 17/7/14 DH: Now check that the price is valid for the spec and that we haven't been hacked!
          
          # 17/7/14 DH: Need to save the line item to be able to access it via the Active Record association 
          #
          # 30/4/15 DH: The variant needs to be in stock or back-orderable to prevent this being rolled-back!
          line_item.save
                    
          if line_item.bsc_req.dynamic_price_invalid?
            #raise "The dynamic price is incorrect"
#debugger
            message = "The dynamic price is incorrect"
            # 18/6/15 DH: With Spree-2.3 to Spree-2.4 upgrade 'line_item.errors' is not used any more
            #         (prob because it gets cleared during the validations after an 'ActiveRecord.save')
            #         Likewise with 'bsc_req.errors' so now using a separate array in 'bsc_req' for extra messages.
            #line_item.bsc_req.errors.add(:base,message)
            line_item.bsc_req.msgs = [message]
            
            Rails.logger.error "\n*** #{message} ***\n\n"
            
            line_item.bsc_req.price_error = true
            
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

    end # END: addDynamicPriceReq

  end # END: DynamicHelper
end # END: module Spree