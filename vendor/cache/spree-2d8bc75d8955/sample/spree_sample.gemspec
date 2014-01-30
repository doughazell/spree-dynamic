# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "spree_sample"
  s.version = "2.1.4.beta"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sean Schofield"]
  s.date = "2014-01-30"
  s.description = "Required dependency for Spree"
  s.email = "sean@spreecommerce.com"
  s.files = ["LICENSE", "lib/spree", "lib/spree/sample.rb", "lib/spree_sample.rb", "lib/tasks", "lib/tasks/sample.rake", "db/samples", "db/samples/addresses.rb", "db/samples/adjustments.rb", "db/samples/assets.rb", "db/samples/images", "db/samples/images/apache_baseball.png", "db/samples/images/ror_bag.jpeg", "db/samples/images/ror_baseball.jpeg", "db/samples/images/ror_baseball_back.jpeg", "db/samples/images/ror_baseball_jersey_back_blue.png", "db/samples/images/ror_baseball_jersey_back_green.png", "db/samples/images/ror_baseball_jersey_back_red.png", "db/samples/images/ror_baseball_jersey_blue.png", "db/samples/images/ror_baseball_jersey_green.png", "db/samples/images/ror_baseball_jersey_red.png", "db/samples/images/ror_jr_spaghetti.jpeg", "db/samples/images/ror_mug.jpeg", "db/samples/images/ror_mug_back.jpeg", "db/samples/images/ror_ringer.jpeg", "db/samples/images/ror_ringer_back.jpeg", "db/samples/images/ror_stein.jpeg", "db/samples/images/ror_stein_back.jpeg", "db/samples/images/ror_tote.jpeg", "db/samples/images/ror_tote_back.jpeg", "db/samples/images/ruby_baseball.png", "db/samples/images/spree_bag.jpeg", "db/samples/images/spree_jersey.jpeg", "db/samples/images/spree_jersey_back.jpeg", "db/samples/images/spree_mug.jpeg", "db/samples/images/spree_mug_back.jpeg", "db/samples/images/spree_ringer_t.jpeg", "db/samples/images/spree_ringer_t_back.jpeg", "db/samples/images/spree_spaghetti.jpeg", "db/samples/images/spree_stein.jpeg", "db/samples/images/spree_stein_back.jpeg", "db/samples/images/spree_tote_back.jpeg", "db/samples/images/spree_tote_front.jpeg", "db/samples/option_types.rb", "db/samples/option_values.rb", "db/samples/orders.rb", "db/samples/payment_methods.rb", "db/samples/payments.rb", "db/samples/product_option_types.rb", "db/samples/product_properties.rb", "db/samples/products.rb", "db/samples/prototypes.rb", "db/samples/shipping_categories.rb", "db/samples/shipping_methods.rb", "db/samples/stock.rb", "db/samples/tax_categories.rb", "db/samples/tax_rates.rb", "db/samples/taxonomies.rb", "db/samples/taxons.rb", "db/samples/variants.rb", "db/samples.rb"]
  s.homepage = "http://spreecommerce.com"
  s.licenses = ["BSD-3"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["none"]
  s.rubygems_version = "1.8.25"
  s.summary = "Sample data (including images) for use with Spree."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>, ["= 2.1.4.beta"])
    else
      s.add_dependency(%q<spree_core>, ["= 2.1.4.beta"])
    end
  else
    s.add_dependency(%q<spree_core>, ["= 2.1.4.beta"])
  end
end
