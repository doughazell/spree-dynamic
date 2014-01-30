# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "spree"
  s.version = "2.1.4.beta"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.8.23") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sean Schofield"]
  s.date = "2014-01-30"
  s.description = "Spree is an open source e-commerce framework for Ruby on Rails.  Join us on the spree-user google group or in #spree on IRC"
  s.email = "sean@spreecommerce.com"
  s.files = ["README.md", "lib/sandbox.sh", "lib/spree.rb"]
  s.homepage = "http://spreecommerce.com"
  s.licenses = ["BSD-3"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["none"]
  s.rubygems_version = "1.8.25"
  s.summary = "Full-stack e-commerce framework for Ruby on Rails."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>, ["= 2.1.4.beta"])
      s.add_runtime_dependency(%q<spree_api>, ["= 2.1.4.beta"])
      s.add_runtime_dependency(%q<spree_backend>, ["= 2.1.4.beta"])
      s.add_runtime_dependency(%q<spree_frontend>, ["= 2.1.4.beta"])
      s.add_runtime_dependency(%q<spree_sample>, ["= 2.1.4.beta"])
      s.add_runtime_dependency(%q<spree_cmd>, ["= 2.1.4.beta"])
    else
      s.add_dependency(%q<spree_core>, ["= 2.1.4.beta"])
      s.add_dependency(%q<spree_api>, ["= 2.1.4.beta"])
      s.add_dependency(%q<spree_backend>, ["= 2.1.4.beta"])
      s.add_dependency(%q<spree_frontend>, ["= 2.1.4.beta"])
      s.add_dependency(%q<spree_sample>, ["= 2.1.4.beta"])
      s.add_dependency(%q<spree_cmd>, ["= 2.1.4.beta"])
    end
  else
    s.add_dependency(%q<spree_core>, ["= 2.1.4.beta"])
    s.add_dependency(%q<spree_api>, ["= 2.1.4.beta"])
    s.add_dependency(%q<spree_backend>, ["= 2.1.4.beta"])
    s.add_dependency(%q<spree_frontend>, ["= 2.1.4.beta"])
    s.add_dependency(%q<spree_sample>, ["= 2.1.4.beta"])
    s.add_dependency(%q<spree_cmd>, ["= 2.1.4.beta"])
  end
end
