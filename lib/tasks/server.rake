# frozen_string_literal: true

require 'solr_wrapper'

desc 'Run test suite'
task :ci do
  if Rails.env.test?
    run_solr('test', port: '8985') do
      Rake::Task['pulsearch:solr:index'].invoke
      Rake::Task['spec'].invoke
    end
  else
    system('rake ci RAILS_ENV=test')
  end
end

desc 'Run solr and orangelight for interactive development'
task :server, [:rails_server_args] do |_t, args|
  run_solr('development', port: '8983') do
    Rake::Task['pulsearch:solr:index'].invoke
    system "bundle exec rails s #{args[:rails_server_args]}"
  end
end

namespace :server do
  desc 'Run development solr'
  task :dev do
    run_solr('development', port: '8983') do
      Rake::Task['pulsearch:solr:index'].invoke
      sleep
    end
  end

  desc 'Run test solr'
  task :test do
    if Rails.env.test?
      run_solr('test', port: '8888') do
        Rake::Task['pulsearch:solr:index'].invoke
        sleep
      end
    else
      system('rake server:test RAILS_ENV=test')
    end
  end
end

def run_solr(environment, solr_params)
  solr_dir = File.join(File.expand_path('.', File.dirname(__FILE__)), '../../', 'solr')
  SolrWrapper.wrap(solr_params) do |solr|
    ENV['SOLR_TEST_PORT'] = solr.port

    # additional solr configuration
    Rake::Task['pulsearch:solr:update'].invoke(solr_dir)
    solr.with_collection(name: "blacklight-core-#{environment}", dir: File.join(solr_dir, 'conf')) do
      puts "\n#{environment.titlecase} solr server running: http://localhost:#{solr.port}/solr/#/blacklight-core-#{environment}"
      puts "\n^C to stop"
      puts ' '
      begin
        yield
      rescue Interrupt
        puts 'Shutting down...'
      end
    end
  end
end
