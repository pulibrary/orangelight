# frozen_string_literal: true

require 'coveralls'
require 'capybara/poltergeist'
require 'webmock/rspec'
require 'factory_bot'

# allow connections to localhost, umlaut and bibdata marc record service
WebMock.disable_net_connect!(allow_localhost: true)

Coveralls.wear!('rails') do
  add_filter '/lib/orangelight/browse_lists.rb'
  add_filter '/app/models/orangelight.rb'
  add_filter '/lib/tasks'
  add_filter 'app/controllers/saved_searches_controller.rb'
  add_filter 'app/controllers/search_history_controller.rb'
end

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60)
end
Capybara.javascript_driver = :poltergeist

def in_ci?
  !ENV['CI'].nil? && ENV['CI'] == 'true'
end
