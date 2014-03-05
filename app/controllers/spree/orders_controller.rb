module Spree
  class OrdersController < Spree::StoreController
    ssl_required :show

    before_filter :check_authorization
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products', 'spree/orders'

    respond_to :html
    
    # 25/2/14 DH: Allow ROMANCARTXML feedback (but check romancart 'storeid' + 'order-items' match 'views/spree/orders/_form.html.erb')
    protect_from_forgery :except => :completed

    def show
      @order = Order.find_by_number!(params[:id])
    end

    def update
      @order = current_order
      unless @order
        flash[:error] = Spree.t(:order_not_found)
        redirect_to root_path and return
      end

      if @order.update_attributes(order_params)
        @order.line_items = @order.line_items.select {|li| li.quantity > 0 }
        @order.ensure_updated_shipments
        return if after_update_attributes

        fire_event('spree.order.contents_changed')

        respond_with(@order) do |format|
          format.html do
            if params.has_key?(:checkout)
              @order.next if @order.cart?
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to cart_path
            end
          end
        end
      else
        respond_with(@order)
      end
    end

    # Shows the current incomplete order from the session
    def edit
      @order = current_order(true)
      associate_user
    end

    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      populator = Spree::OrderPopulator.new(current_order(true), current_currency)
      
      # 28/12/13 DH: Allow LineItem.bsc_spec to be populated with Rails 4 'strong_parameters'
      params.permit(:bsc_spec)
      
      # 28/12/13 DH: Retrieve the BSC spec and dynamic price sent from 'views/spree/products/show.html.erb'
      if populator.populate(params.slice(:products, :variants, :quantity, :price, :spec))
        current_order.ensure_updated_shipments

        fire_event('spree.cart.add')
        fire_event('spree.order.contents_changed')
        respond_with(@order) do |format|
          format.html { redirect_to cart_path }
        end
      else
        flash[:error] = populator.errors.full_messages.join(" ")
        redirect_to :back
      end
    end

    # ------------------------- BSC additions ---------------------------
    # 28/12/13 DH: Creating a method to be called by Romancart with 'ROMANCARTXML' to indicate a completed order
    #              '/config/routes.rb':- "match 'cart/completed' => 'spree/orders#completed', :via => :post"        
    def completed

      #@order = current_order
      
      posted_xml = params[:ROMANCARTXML]

      # Remove XHTML character encoding (hopefully won't need to do this when we receive XML message from RomanCart!)
      xml = posted_xml.sub("<?xml version='1.0' encoding='UTF-8'?>", "")
      
      xml_doc  = Nokogiri::XML(xml)   
     
      total_price = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content
      orders = Spree::Order.where("state = ? AND total = ?", "cart",total_price)
      Rails.logger.info "#{orders.count} orders in 'cart' state with a price of #{total_price}"
      
      if orders.count == 0
        # 5/3/14 DH: Testing ROMANCARTXML feedback locally so price is fixed
        orders = Spree::Order.where("state = ? AND total = ?", "cart","8.40")
      end

      @order = orders.last
      Rails.logger.info "Order number selected: #{@order.number}"

      if @order
        
        @order.email = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/email").first.content
        
        @order.user_id = xml_doc.xpath("/romancart-transaction-data/orderid").first.content
        
        @order.number = xml_doc.xpath("/romancart-transaction-data/orderid").first.content        
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
        if @order.item_total == 0
          
          while @order.state != "complete"
            @order.next!
          end
          
        else
          
          while @order.state != "payment"
            @order.next!
            Rails.logger.info "Order number '#{@order.number}' is in state:#{@order.state}" 
          end
          
          if xml_doc.xpath("/romancart-transaction-data/paid-flag").first.content.eql?("True")
          #if xml_doc.xpath("/romancart-transaction-data/paid-flag").first.content.eql?("False")
            Rails.logger.info "Testing ROMANCARTXML feedback using cheque payment so '<paid-flag>False</paid-flag>'"

            unless @order.payments.exists?
              # 5/3/14 DH: Previously this worked for 'spree-2.0.4' but the payments system was changed in 'spree-2.1'
              #@order.payments.create!(:amount => @order.total)
              #@order.payments.last.payment_method = Spree::PaymentMethod.find_by_name("RomanCart")
            
              # 5/3/14 DH: Taken this from 'spree/2-1-stable/api/app/models/spree/order_decorator.rb'              
              payment = @order.payments.build
              payment.amount = @order.total
              payment.state = "completed"
              payment.payment_method = Spree::PaymentMethod.find_by_name("RomanCart")
              payment.save!
	      
              if @order.payments.last.payment_method
                Rails.logger.info "Creating #{@order.payments.last.payment_method.name} payment of #{@order.total}"
              else
                Rails.logger.info "RomanCart payment method not found!"
              end
            end
            
            # '@order.payments' is an array so need to get last one entered to access 'Spree::Payment' methods
            @order.payments.last.complete
            
            @order.payment_total = @order.total

            # To 6 - Complete
            @order.state = "complete"
            @order.completed_at = Time.now
            @order.save!
	          Rails.logger.info "Order number '#{@order.number}' is in state:#{@order.state}"
          end
        end

      else # No current order (prob because of the CSRF error preventing Devise access the current order session)
        Rails.logger.info "Well that's what Devise does since there's no CSRF authenticy...doh!"
      end

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
    # ------------------------- END BSC additions ---------------------------

    def empty
      if @order = current_order
        @order.empty!
      end

      redirect_to spree.cart_path
    end

    def accurate_title
      @order && @order.completed? ? "#{Spree.t(:order)} #{@order.number}" : Spree.t(:shopping_cart)
    end

    def check_authorization
      session[:access_token] ||= params[:token]
      order = Spree::Order.find_by_number(params[:id]) || current_order

      if order
        authorize! :edit, order, session[:access_token]
      else
        authorize! :create, Spree::Order
      end
    end

    private

      def order_params
        if params[:order]
          params[:order].permit(*permitted_order_attributes)
        else
          {}
        end
      end

      def after_update_attributes
        coupon_result = Spree::Promo::CouponApplicator.new(@order).apply
        if coupon_result[:coupon_applied?]
          flash[:success] = coupon_result[:success] if coupon_result[:success].present?
          return false
        else
          flash.now[:error] = coupon_result[:error]
          respond_with(@order) { |format| format.html { render :edit } }
          return true
        end
      end
  end
end
