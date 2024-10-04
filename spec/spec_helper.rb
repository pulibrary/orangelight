# frozen_string_literal: true
def in_ci?
  !ENV['CI'].nil? && ENV['CI'] == 'true'
end

require 'coveralls' if in_ci?
require 'factory_bot'
require 'webmock/rspec'

# allow connections to localhost and bibdata marc record service
WebMock.disable_net_connect!(allow_localhost: true,
                             allow: 'chromedriver.storage.googleapis.com')

if in_ci?
  Coveralls.wear!('rails') do
    add_filter '/lib/orangelight/browse_lists.rb'
    add_filter '/app/models/orangelight.rb'
    add_filter '/lib/tasks'
    add_filter 'app/controllers/search_history_controller.rb'
  end
end

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
end

ENV['GRAPHQL_API_URL'] = 'https://figgy.princeton.edu/graphql' unless ENV['GRAPHQL_API_URL']
ENV['FIGGY_URL'] = 'https://figgy.princeton.edu' unless ENV['FIGGY_URL']
