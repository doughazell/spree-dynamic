# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "spree_cmd"
  s.version = "2.1.4.beta"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Mar"]
  s.date = "2014-01-30"
  s.description = "tools to create new Spree stores and extensions"
  s.email = ["chris@spreecommerce.com"]
  s.executables = ["spree", "spree_cmd"]
  s.files = ["LICENSE", "README.md", "Rakefile", "bin/spree", "bin/spree_cmd", "lib/spree_cmd.rb", "lib/spree_cmd/extension.rb", "lib/spree_cmd/installer.rb", "lib/spree_cmd/templates/extension/CONTRIBUTING.md", "lib/spree_cmd/templates/extension/Gemfile", "lib/spree_cmd/templates/extension/LICENSE", "lib/spree_cmd/templates/extension/README.md", "lib/spree_cmd/templates/extension/Rakefile", "lib/spree_cmd/templates/extension/app/assets/javascripts/admin/%file_name%.js", "lib/spree_cmd/templates/extension/app/assets/javascripts/store/%file_name%.js", "lib/spree_cmd/templates/extension/app/assets/stylesheets/admin/%file_name%.css", "lib/spree_cmd/templates/extension/app/assets/stylesheets/store/%file_name%.css", "lib/spree_cmd/templates/extension/bin/rails.tt", "lib/spree_cmd/templates/extension/config/locales/en.yml", "lib/spree_cmd/templates/extension/config/routes.rb", "lib/spree_cmd/templates/extension/extension.gemspec", "lib/spree_cmd/templates/extension/gitignore", "lib/spree_cmd/templates/extension/lib/%file_name%.rb.tt", "lib/spree_cmd/templates/extension/lib/%file_name%/engine.rb.tt", "lib/spree_cmd/templates/extension/lib/%file_name%/factories.rb.tt", "lib/spree_cmd/templates/extension/lib/generators/%file_name%/install/install_generator.rb.tt", "lib/spree_cmd/templates/extension/rspec", "lib/spree_cmd/templates/extension/spec/spec_helper.rb.tt", "lib/spree_cmd/version.rb", "spec/spec_helper.rb", "spree_cmd.gemspec"]
  s.homepage = "http://spreecommerce.com"
  s.licenses = ["BSD-3"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "spree_cmd"
  s.rubygems_version = "1.8.25"
  s.summary = "Spree Commerce command line utility"
  s.test_files = ["spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<thor>, ["~> 0.14"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<thor>, ["~> 0.14"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<thor>, ["~> 0.14"])
  end
end
