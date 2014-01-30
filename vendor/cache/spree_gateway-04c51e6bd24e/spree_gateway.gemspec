# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "spree_gateway"
  s.version = "2.1.0.beta"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Spree Commerce"]
  s.date = "2014-01-30"
  s.description = "Additional Payment Gateways for Spree Commerce"
  s.email = "ryan@spreecommerce.com"
  s.homepage = "http://www.spreecommerce.org"
  s.licenses = ["BSD-3"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["none"]
  s.rubygems_version = "1.8.25"
  s.summary = "Additional Payment Gateways for Spree Commerce"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>, ["~> 2.1"])
      s.add_runtime_dependency(%q<savon>, ["~> 1.2"])
      s.add_development_dependency(%q<factory_girl_rails>, ["~> 4.2.0"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.13"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<capybara>, ["= 2.1.0"])
      s.add_development_dependency(%q<launchy>, [">= 0"])
    else
      s.add_dependency(%q<spree_core>, ["~> 2.1"])
      s.add_dependency(%q<savon>, ["~> 1.2"])
      s.add_dependency(%q<factory_girl_rails>, ["~> 4.2.0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.13"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<capybara>, ["= 2.1.0"])
      s.add_dependency(%q<launchy>, [">= 0"])
    end
  else
    s.add_dependency(%q<spree_core>, ["~> 2.1"])
    s.add_dependency(%q<savon>, ["~> 1.2"])
    s.add_dependency(%q<factory_girl_rails>, ["~> 4.2.0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.13"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<capybara>, ["= 2.1.0"])
    s.add_dependency(%q<launchy>, [">= 0"])
  end
end
