unless defined?(Spree::InstallGenerator)
  require 'generators/spree/install/install_generator'
end

require 'generators/spree/dummy/dummy_generator'

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app, :user_class do |t, args|
    args.with_defaults(:user_class => "Spree::LegacyUser")
    require "#{ENV['LIB_NAME']}"

    puts "'Spree::DummyGenerator.start --lib_name=#{ENV['LIB_NAME']}'"
    Spree::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet", "--doug=pissed off"]
    puts "'Spree::InstallGenerator.start'"
    Spree::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=#{args[:user_class]}"]

    puts "Setting up dummy database..."
    cmd = "bundle exec rake db:drop db:create db:migrate db:test:prepare"

    if RUBY_PLATFORM =~ /mswin/ #windows
      cmd += " >nul"
    else
      cmd += " >/dev/null"
    end

    system(cmd)

    begin
      require "generators/#{ENV['LIB_NAME']}/install/install_generator"
      puts 'Running extension installation generator...'
      "#{ENV['LIB_NAME'].camelize}::Generators::InstallGenerator".constantize.start(["--auto-run-migrations"])
    rescue LoadError
      puts 'Skipping installation no generator to run...'
    end
  end

  task :seed do |t, args|
    puts "Seeding ..."
    cmd = "bundle exec rake db:seed RAILS_ENV=test"

    if RUBY_PLATFORM =~ /mswin/ #windows
      cmd += " >nul"
    else
      cmd += " >/dev/null"
    end

    system(cmd)
  end
end
