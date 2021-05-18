# frozen_string_literal: true
require 'coveralls'
require 'factory_bot'
require 'webmock/rspec'

# allow connections to localhost, umlaut and bibdata marc record service
WebMock.disable_net_connect!(allow_localhost: true,
                             allow: 'chromedriver.storage.googleapis.com')

Coveralls.wear!('rails') do
  add_filter '/lib/orangelight/browse_lists.rb'
  add_filter '/app/models/orangelight.rb'
  add_filter '/lib/tasks'
  add_filter 'app/controllers/search_history_controller.rb'
end

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
end

def in_ci?
  !ENV['CI'].nil? && ENV['CI'] == 'true'
end

ENV['GRAPHQL_API_URL'] = 'https://figgy.princeton.edu/graphql' unless ENV['GRAPHQL_API_URL']
ENV['FIGGY_URL'] = 'https://figgy.princeton.edu' unless ENV['FIGGY_URL']
