# frozen_string_literal: true

namespace :yarn do
  desc 'Run jest tests'
  task :test do
    sh('yarn', 'test') if Rails.env.test? || Rails.env.development?
  end
end

namespace :servers do
  task initialize: :environment do
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["pulsearch:solr:index"].invoke
  end

  desc "Start the Apache Solr and PostgreSQL container services using Lando."
  task start: :environment do
    system("lando start")
    system("rake servers:initialize")
    system("rake servers:initialize RAILS_ENV=test")
  end

  desc "Stop the Lando Apache Solr and PostgreSQL container services."
  task stop: :environment do
    system("lando stop")
  end
end

namespace :server do
  desc 'Run development solr'
  task :dev do
    Rake::Task['pulsearch:solr:index'].invoke
    puts("Indexing to Lando. Running at http://localhost:#{ENV['lando_orangelight_development_solr_conn_port']}")
  end

  desc 'Run test solr'
  task :test do
    if Rails.env.test?
      Rake::Task['pulsearch:solr:index'].invoke
      puts("Indexing to Lando. Running at http://localhost:#{ENV['lando_orangelight_test_solr_conn_port']}")
    else
      system('rake server:test RAILS_ENV=test')
    end
  end

  desc 'Load test against Solr'
  task :load_test_solr do
    solr_uri = run_lando_solr

    siege_file = Tempfile.new('siege.json')
    system("/usr/bin/env siege --internet --concurrent=5 --time=10S --json-output #{solr_uri} > #{siege_file.path}")

    siege_file.read
    siege_file.close
    puts("Please find the siege test results in #{siege_file.path}")
  end

  desc 'Load test against Rails'
  task :load_test, [:rails_server_args] do |_t, args|
    solr_uri = run_lando_solr

    Open3.popen3("/usr/bin/env bundle exec rails server #{args[:rails_server_args]}") do |_stdin, _stdout, _stderr, _wait_thr|
      siege_file = Tempfile.new('siege.json')
      system("/usr/bin/env siege --internet --concurrent=5 --time=10S --json-output #{solr_uri} > #{siege_file.path}")

      siege_file.read
      siege_file.close
      puts("Please find the siege test results in #{siege_file.path}")
    end
  end
end

def run_lando_solr
  scheme = 'http'
  host = 'localhost'
  port = nil
  path = nil

  if Rails.env.test?
    port = if ENV["lando_orangelight_test_solr_conn_port"]
             ENV['lando_orangelight_test_solr_conn_port']
           else
             '8888'
           end

    path = "/solr/orangelight-core-test/select"
  else
    port = if ENV["lando_orangelight_development_solr_conn_port"]
             ENV['lando_orangelight_development_solr_conn_port']
           else
             '8983'
           end

    path = "/solr/orangelight-core-development/select"
  end

  Rake::Task['pulsearch:solr:index'].invoke
  URI::HTTP.build(scheme: scheme, host: host, port: port, path: path)
end
