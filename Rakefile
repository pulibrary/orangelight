# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rspec/core/rake_task'
require 'jettywrapper'


Rails.application.load_tasks

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.10.0.zip"


Rake::Task["jetty:clean"].enhance do
  Rake::Task["pulsearch:solr2jetty"].invoke
end



task :ci do

  jetty_params = Jettywrapper.load_config.merge(
      {:jetty_home => File.expand_path(File.dirname(__FILE__) + '/jetty'),
       :startup_wait => 180,
       :jetty_port => ENV['TEST_JETTY_PORT'] || 8983
      }
  )

  Rake::Task['jetty:download'].invoke
  Rake::Task['jetty:clean'].invoke
  error = nil
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end


  raise "test failures: #{error}" if error
end

# Rake::Task[:default].prerequisites.clear
task :default => []; Rake::Task[:default].clear
task :default => [:ci]