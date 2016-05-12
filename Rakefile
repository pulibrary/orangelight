# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

ZIP_URL = 'https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.0.zip'.freeze

require 'jettywrapper'
require 'rubocop/rake_task'

Rails.application.load_tasks

Rake::Task['jetty:clean'].enhance do
  Rake::Task['pulsearch:solr2jetty'].invoke
end

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run test suite and style checker'
task spec: :rubocop

desc 'Spin up solr and run tests'
task :ci do
  if Rails.env.test?
    # setup test database
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke

    Rake::Task['jetty:clean'].invoke

    jetty_params = Jettywrapper.load_config
    jetty_params[:startup_wait] = 180

    Jettywrapper.wrap(jetty_params) do
      # load fixtures
      Rake::Task['pulsearch:index'].invoke

      # run the tests
      Rake::Task['spec'].invoke
    end
  else
    system('rake ci RAILS_ENV=test')
  end
end

Rake::Task[:default].clear
task default: :ci
