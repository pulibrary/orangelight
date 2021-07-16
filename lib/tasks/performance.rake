# frozen_string_literal: true

require Rails.root.join('spec', 'support', 'load_test_job')

def lando_solr_uri
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

namespace :performance do
  namespace :solr do
    desc 'Performing load testing against the local Solr environment'
    task :test, [:time] do |_t, args|
      time = args[:time]

      siege_file = Tempfile.new('siege.json')
      system("/usr/bin/env siege --internet --concurrent=5 --time=#{time} --json-output #{lando_solr_uri} > #{siege_file.path}")

      siege_file.read
      siege_file.close
      STDOUT.puts("Please find the Solr performance test results in #{siege_file.path}")
    end
  end

  desc 'Performing load testing against the production Rails environment'
  task :test, [:requests] do |_t, args|
    requests = args[:requests]
    results = LoadTestJob.perform_now(requests: requests.to_i)

    results_file = Tempfile.new('load_test.csv')

    CSV.open(results_file.path, "wb") do |csv|
      csv << results.headings
      results.rows.each do |row|
        csv << row
      end
    end

    table = Terminal::Table.new(title: "Load Test Results", headings: results.headings, rows: results.rows)
    STDOUT.puts(table)
    STDOUT.puts("Please find the Rails app. test results in #{results_file.path}")
  end
end
