# frozen_string_literal: true

require 'capybara/rspec'
require 'coveralls'
require 'factory_bot'
require 'selenium/webdriver'
require 'webmock/rspec'

# allow connections to localhost, umlaut and bibdata marc record service
WebMock.disable_net_connect!(allow_localhost: true)

Coveralls.wear!('rails') do
  add_filter '/lib/orangelight/browse_lists.rb'
  add_filter '/app/models/orangelight.rb'
  add_filter '/lib/tasks'
  add_filter 'app/controllers/saved_searches_controller.rb'
  add_filter 'app/controllers/search_history_controller.rb'
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu disable-setuid-sandbox window-size=7680,4320] }
  )

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities,
                                 http_client: http_client)
end
Capybara.javascript_driver = :headless_chrome

Capybara.register_driver :iphone do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu disable-setuid-sandbox window-size=7680,4320 use-mobile-user-agent user-agent=iPhone] }
  )

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities,
                                 http_client: http_client)
end

Capybara.default_max_wait_time = 60

def in_ci?
  !ENV['CI'].nil? && ENV['CI'] == 'true'
end

ENV['GRAPHQL_API_URL'] = 'https://figgy.princeton.edu/graphql' unless ENV['GRAPHQL_API_URL']
ENV['FIGGY_URL'] = 'https://figgy.princeton.edu' unless ENV['FIGGY_URL']
