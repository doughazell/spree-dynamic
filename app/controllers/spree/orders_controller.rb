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
#debugger
      # 14/7/15 DH: Passing BSC Req dynamic price hacks back to web
      if line_item && (line_item.bsc_req.price_error == true)
        error = line_item.bsc_req.msgs.join(" ")
      end

      if error
        flash[:error] = error

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
