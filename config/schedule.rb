# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

set :job_template, "bash -l -c 'export PATH=\"/usr/local/bin/:$PATH\" && :job'"

job_type :browse_facet_update, 'cd :path && :environment_variable=:environment SOLR_URL=:solr_url :bundle_command rake :task --silent :output'

every [:sunday, :wednesday, :friday], at: '1:15am', roles: [:cron_prod1] do
  browse_facet_update(
    'browse:call_numbers',
    solr_url: 'http://lib-solr3.princeton.edu:8983/solr/catalog-production',
    output: '/tmp/cron_log.log'
  )
end

every [:sunday, :wednesday, :friday], at: '6:20am', roles: [:cron_prod1] do
  browse_facet_update(
    'browse:load_call_numbers',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

every [:tuesday, :thursday, :saturday], at: '2:00am', roles: [:cron_prod1] do
  browse_facet_update(
    'browse:name_titles',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

every [:tuesday, :thursday, :saturday], at: '6:00am', roles: [:cron_prod1] do
  browse_facet_update(
    'browse:load_name_titles',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

every 1.day, at: '2:30am', roles: [:cron_prod2] do
  browse_facet_update(
    'browse:names',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

every 1.day, at: '5:50am', roles: [:cron_prod2] do
  browse_facet_update(
    'browse:load_names',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

every 1.day, at: '3:00am', roles: [:cron_prod3] do
  browse_facet_update(
    'browse:subjects',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

every 1.day, at: '6:10am', roles: [:cron_prod3] do
  browse_facet_update(
    'browse:load_subjects',
    solr_url: ENV['SOLR_URL'],
    output: '/tmp/cron_log.log'
  )
end

job_type :logging_rake, 'cd :path && :environment_variable=:environment bundle exec rake :task :output'

every :tuesday, at: '2:00am', roles: [:sitemap] do
  logging_rake 'sitemap:refresh', output: { error: '/tmp/ol_sitemap.log', standard: '/tmp/ol_sitemap.log' }
end
