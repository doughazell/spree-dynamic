# 14/6/14 DH: Adding a helper for common code in 'spree/orders#completed' and 'ApplicationHelper::createRomancartXML'
include Spree::DynamicHelper

module Spree
  class OrdersController < Spree::StoreController
    before_action :check_authorization
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/products', 'spree/orders'

    respond_to :html

    before_action :assign_order_with_lock, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

    # 25/2/14 DH: Allow ROMANCARTXML feedback (but check romancart 'storeid' + 'order-items' match 'views/spree/orders/_form.html.erb')
    protect_from_forgery :except => :completed

    # 13/7/15 DH: External wrapper for BSC unsupported offsite payment gateway
    def completed
      posted_xml = params[:ROMANCARTXML]
      completed_mechanism(posted_xml)
    end

    def show
      @order = Order.find_by_number!(params[:id])
    end

    def update
      if @order.contents.update_cart(order_params)
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
      @order = current_order || Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
      associate_user
    end

    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      order    = current_order(create_order_if_necessary: true)
      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].to_i
      options  = params[:options] || {}
      
      # 13/7/15 DH: Passing dynamic price and spec from web page
      order.contents.bscDynamicPrice = BigDecimal.new(params[:price])
      order.contents.bscSpec = params[:spec]
      
if ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'development'      
      # 11/10/16 DH: Solving why Flash msg not cleared in 'dynamic_price_spec.rb' on hacked price
      if params[:sim_price_hack]
        puts "\n----------- YIPPEE - Simulated price hack (via POST args) ------------\n\n"
        unless Spree::BscReq.respond_to?(:price_alteration)
          Spree::BscReq.alterDynamicPrice(-0.41)
        end
      else
        puts "\n-------------- NO Simulated price hack THIS TIME (via POST args) --------------\n\n"

        unless Spree::BscReq.respond_to?(:rspec_alteration)
          puts "\nClearing price alteration set by browser (not RSpec test)...\n\n"          
          Spree::BscReq.clearDynamicPriceAlteration
        end
      end
end

      # 2,147,483,647 is crazy. See issue #2695.
      if quantity.between?(1, 2_147_483_647)
        begin
          # 14/7/15 DH: Passing back BSC error msgs
          line_item = order.contents.add(variant, quantity, options)
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
      else
        error = Spree.t(:please_enter_reasonable_quantity)
      end

      # 14/7/15 DH: Passing BSC Req dynamic price hacks back to web
      if line_item && (line_item.bsc_req.price_error)
        error = line_item.bsc_req.msgs.join(" ")
        #puts line_item.bsc_req.inspect
        
        # 11/10/16 DH: Need to clear class attribs after use (or maybe not...)
        #Spree::BscReq.msgs = []
        #Spree::BscReq.price_error = false
        
        # 11/10/16 DH: Also need to remove the line_item from the cart since invalid
        order.contents.remove(variant, quantity, options)
      end

      if error
        #flash[:error] = error

        # 11/10/16 DH: Getting 'Spree::BscReq.clearDynamicPriceAlteration' to work in 'dynamic_price_spec.rb'
        flash.now[:error] = error

        # 22/7/14 DH: Displaying flash message after BSC error when submit via AJAX
        respond_with(order) do |format|
          format.html { redirect_back_or_default(spree.root_path) }
          
          # 23/7/14 DH: Since 'format.js' has no overriding block then it uses the default for the 
          #             'Controller#Action' of 'views/spree/orders/populate.js.coffee'
          # 15/7/15 DH: And doesn't even need to be specified... :)
          #format.js
        end
      else
        respond_with(order) do |format|
          format.html { redirect_to cart_path }
        end
      end
    end

    def empty
      if @order = current_order
        @order.empty!
      end

      redirect_to spree.cart_path
    end

    def accurate_title
      if @order && @order.completed?
        Spree.t(:order_number, :number => @order.number)
      else
        Spree.t(:shopping_cart)
      end
    end

    def check_authorization
      order = Spree::Order.find_by_number(params[:id]) || current_order

      if order
        authorize! :edit, order, cookies.signed[:guest_token]
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

      def assign_order_with_lock
        @order = current_order(lock: true)
        unless @order
          flash[:error] = Spree.t(:order_not_found)
          redirect_to root_path and return
        end
      end
  end
end
