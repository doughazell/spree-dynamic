# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "spree_auth_devise"
  s.version = "2.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sean Schofield"]
  s.date = "2014-01-30"
  s.description = "Required dependency for Spree"
  s.email = "sean@spreecommerce.com"
  s.files = ["LICENSE", "README.md", "app/assets", "app/assets/javascripts", "app/assets/javascripts/admin", "app/assets/javascripts/admin/spree_auth.js", "app/assets/javascripts/store", "app/assets/javascripts/store/spree_auth.js", "app/assets/stylesheets", "app/assets/stylesheets/admin", "app/assets/stylesheets/admin/spree_auth.css", "app/assets/stylesheets/store", "app/assets/stylesheets/store/spree_auth.css", "app/controllers", "app/controllers/metal_decorator.rb", "app/controllers/spree", "app/controllers/spree/admin", "app/controllers/spree/admin/admin_controller_decorator.rb", "app/controllers/spree/admin/admin_orders_controller_decorator.rb", "app/controllers/spree/admin/admin_resource_controller_decorator.rb", "app/controllers/spree/admin/users_controller.rb", "app/controllers/spree/base_controller_decorator.rb", "app/controllers/spree/checkout_controller_decorator.rb", "app/controllers/spree/orders_controller_decorator.rb", "app/controllers/spree/user_passwords_controller.rb", "app/controllers/spree/user_registrations_controller.rb", "app/controllers/spree/user_sessions_controller.rb", "app/controllers/spree/users_controller.rb", "app/helpers", "app/helpers/spree", "app/helpers/spree/users_helper.rb", "app/mailers", "app/mailers/spree", "app/mailers/spree/user_mailer.rb", "app/models", "app/models/spree", "app/models/spree/auth_configuration.rb", "app/models/spree/user.rb", "app/overrides", "app/overrides/admin_tab.rb", "app/overrides/auth_admin_login_navigation_bar.rb", "app/overrides/auth_shared_login_bar.rb", "app/overrides/auth_user_login_form.rb", "app/views", "app/views/spree", "app/views/spree/admin", "app/views/spree/admin/_users_tab.html.erb", "app/views/spree/admin/users", "app/views/spree/admin/users/_form.html.erb", "app/views/spree/admin/users/edit.html.erb", "app/views/spree/admin/users/index.html.erb", "app/views/spree/admin/users/new.html.erb", "app/views/spree/admin/users/show.html.erb", "app/views/spree/checkout", "app/views/spree/checkout/registration.html.erb", "app/views/spree/layouts", "app/views/spree/layouts/admin", "app/views/spree/layouts/admin/_login_nav.html.erb", "app/views/spree/shared", "app/views/spree/shared/_flashes.html.erb", "app/views/spree/shared/_login.html.erb", "app/views/spree/shared/_login_bar.html.erb", "app/views/spree/shared/_user_form.html.erb", "app/views/spree/user_mailer", "app/views/spree/user_mailer/reset_password_instructions.text.erb", "app/views/spree/user_passwords", "app/views/spree/user_passwords/edit.html.erb", "app/views/spree/user_passwords/new.html.erb", "app/views/spree/user_registrations", "app/views/spree/user_registrations/new.html.erb", "app/views/spree/user_sessions", "app/views/spree/user_sessions/authorization_failure.html.erb", "app/views/spree/user_sessions/new.html.erb", "app/views/spree/users", "app/views/spree/users/edit.html.erb", "app/views/spree/users/show.html.erb", "config/initializers", "config/initializers/devise.rb", "config/initializers/spree.rb", "config/locales", "config/locales/de.yml", "config/locales/en.yml", "config/locales/es.yml", "config/locales/fr.yml", "config/locales/nl.yml", "config/locales/tr.yml", "config/routes.rb", "lib/generators", "lib/generators/spree", "lib/generators/spree/auth", "lib/generators/spree/auth/install", "lib/generators/spree/auth/install/install_generator.rb", "lib/generators/spree/auth/install/templates", "lib/generators/spree/auth/install/templates/config", "lib/generators/spree/auth/install/templates/config/initializers", "lib/generators/spree/auth/install/templates/config/initializers/devise.rb", "lib/spree", "lib/spree/auth", "lib/spree/auth/devise.rb", "lib/spree/auth/engine.rb", "lib/spree/auth.rb", "lib/spree/authentication_helpers.rb", "lib/spree_auth_devise.rb", "lib/tasks", "lib/tasks/auth.rake", "db/default", "db/default/users.rb", "db/migrate", "db/migrate/20101026184949_create_users.rb", "db/migrate/20101026184950_rename_columns_for_devise.rb", "db/migrate/20101214150824_convert_user_remember_field.rb", "db/migrate/20120203010234_add_reset_password_sent_at_to_spree_users.rb", "db/migrate/20120605211305_make_users_email_index_unique.rb", "db/seeds.rb"]
  s.homepage = "http://spreecommerce.com"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.requirements = ["none"]
  s.rubygems_version = "1.8.25"
  s.summary = "Provides authentication and authorization services for use with Spree by using Devise and CanCan."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>, ["~> 2.1.0"])
      s.add_runtime_dependency(%q<spree_frontend>, ["~> 2.1.0"])
      s.add_runtime_dependency(%q<spree_backend>, ["~> 2.1.0"])
      s.add_runtime_dependency(%q<devise>, ["~> 3.2.2"])
      s.add_runtime_dependency(%q<devise-encryptable>, ["= 0.1.2"])
      s.add_runtime_dependency(%q<cancan>, ["~> 1.6.7"])
    else
      s.add_dependency(%q<spree_core>, ["~> 2.1.0"])
      s.add_dependency(%q<spree_frontend>, ["~> 2.1.0"])
      s.add_dependency(%q<spree_backend>, ["~> 2.1.0"])
      s.add_dependency(%q<devise>, ["~> 3.2.2"])
      s.add_dependency(%q<devise-encryptable>, ["= 0.1.2"])
      s.add_dependency(%q<cancan>, ["~> 1.6.7"])
    end
  else
    s.add_dependency(%q<spree_core>, ["~> 2.1.0"])
    s.add_dependency(%q<spree_frontend>, ["~> 2.1.0"])
    s.add_dependency(%q<spree_backend>, ["~> 2.1.0"])
    s.add_dependency(%q<devise>, ["~> 3.2.2"])
    s.add_dependency(%q<devise-encryptable>, ["= 0.1.2"])
    s.add_dependency(%q<cancan>, ["~> 1.6.7"])
  end
end
