# Do not drop database for tests
if ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'development'

  Rake::TaskManager.class_eval do
    def delete_task(task_name)
      @tasks.delete(task_name.to_s)
    end
  end

  Rake.application.delete_task("db:test:load")

  namespace :db do
    namespace :test do
      task :load do
      end
    end
  end

end
