module Spree
  class LineItem < ActiveRecord::Base
    before_validation :adjust_quantity
    belongs_to :order, class_name: "Spree::Order"
    belongs_to :variant, class_name: "Spree::Variant"
    belongs_to :tax_category, class_name: "Spree::TaxCategory"
    
    # 28/4/14 DH: Converting 'bsc_spec' column in 'spree_line_items' to separate table 'spree_bsc_reqs'
    # 1/5/14 DH: Matching 'has_one :line_item, ...' in 'Spree::BscReq' but 'spree_line_items' contains FK 'bsc_req_id'
    belongs_to :bsc_req, class_name: "Spree::BscReq"
    
    # 3/5/14 DH: Try preventing incomplete req set with ':null => false' migration first
    #validates :bsc_req, presence: true, if: Spree::BscReq.valid?

    has_one :product, through: :variant
    has_many :adjustments, as: :adjustable, dependent: :destroy

    before_validation :copy_price
    before_validation :copy_tax_category

    validates :variant, presence: true
    validates :quantity, numericality: {
      only_integer: true,
      greater_than: -1,
      message: Spree.t('validation.must_be_int')
    }
    validates :price, numericality: true
    validates_with Stock::AvailabilityValidator

    before_save :update_inventory

    after_save :update_order
    after_destroy :update_order

    # 23/12/13 DH: Added whilst trying to solve "undefined method `track_inventory?' for #<Spree::Variant" error on "Add To Cart"
    #              Solved by running the Spree Engine migrations: 'rake railties:install:migrations' then 'rake db:migrate'
    #delegate :name, :description, to: :variant
    delegate :name, :description, :should_track_inventory?, to: :variant

    attr_accessor :target_shipment
    
    # 16/12/13 DH: Previously done with 'attr_accessible' via a 'Spree::LineItem.class_eval' but gave error for v2.1.3
    #attr_accessor :bsc_spec

    def copy_price
      if variant
        self.price = variant.price if price.nil?
        self.cost_price = variant.cost_price if cost_price.nil?
        self.currency = variant.currency if currency.nil?
      end
    end

    def copy_tax_category
      if variant
        self.tax_category = variant.product.tax_category
      end
    end

    def amount
      price * quantity
    end
    alias total amount

    def single_money
      Spree::Money.new(price, { currency: currency })
    end
    alias single_display_amount single_money

    def money
      Spree::Money.new(amount, { currency: currency })
    end
    alias display_total money
    alias display_amount money

    def adjust_quantity
      self.quantity = 0 if quantity.nil? || quantity < 0
    end

    def sufficient_stock?
      Stock::Quantifier.new(variant_id).can_supply? quantity
    end

    def insufficient_stock?
      !sufficient_stock?
    end

    def assign_stock_changes_to=(shipment)
      @preferred_shipment = shipment
    end

    # Remove product default_scope `deleted_at: nil`
    def product
      variant.product
    end

    # Remove variant default_scope `deleted_at: nil`
    def variant
      Spree::Variant.unscoped { super }
    end

    private
      def update_inventory
        if changed?
          Spree::OrderInventory.new(self.order).verify(self, target_shipment)
        end
      end

      def update_order
        if changed? || destroyed?
          # update the order totals, etc.
          order.create_tax_charge!
          order.update!
        end
      end
  end
end

