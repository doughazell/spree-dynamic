FactoryGirl.define do
  factory :base_product, class: Spree::Product do
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }
    description { generate(:random_description) }
    
    price 19.99
    cost_price 17.00
    sku 'ABC'
    available_on { 1.year.ago }
    deleted_at nil

    # 28/5/14 DH: r ::= FactoryGirl::SyntaxRunner

    # Returns the first operand of the '||' if true (ie present) as the last statement of block otherwise 
    #   "ActiveRecord::RecordInvalid Validation failed: Shipping category can't be blank"
=begin
    shipping_category { |r| IO.try_convert(STDOUT).puts "\nDOUG:\n#{r.description}\n\n"
                            Spree::ShippingCategory.first || r.association(:shipping_category) }
=end
    shipping_category { |r| Spree::ShippingCategory.first || r.association(:shipping_category) }

    # ensure stock item will be created for this products master
    before(:create) { create(:stock_location) if Spree::StockLocation.count == 0 }

    after(:create) do |p|
      p.variants_including_master.each { |v| v.save! }
      
      # 28/5/14 DH: Investigating 'OrderWalkthrough.up_to(:complete)'
      #IO.try_convert(STDOUT).puts "#{__FILE__} : #{p.description}"
      #puts "#{__FILE__} : #{p.description}"
    end

    factory :custom_product do
      name 'Custom Product'
      price 17.99

      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }
    end

    factory :product do
      tax_category { |r| Spree::TaxCategory.first || r.association(:tax_category) }

      factory :product_with_option_types do
        after(:create) { |product| create(:product_option_type, product: product) }
      end
    end
  end
end
