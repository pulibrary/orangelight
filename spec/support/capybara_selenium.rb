# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/rspec'
require "selenium-webdriver"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver(:selenium) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': { args: %w[disable-gpu disable-setuid-sandbox window-size=7680,4320] }
  )

  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--disable-gpu"

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120

  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 capabilities:,
                                 http_client:,
                                 options: browser_options)
end

# This was needed for my local workstation, perhaps :selenium is overridden elsewhere?
Capybara.register_driver(:selenium_headless) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': { args: %w[headless disable-gpu disable-setuid-sandbox window-size=7680,4320] }
  )

  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--headless"
  browser_options.args << "--disable-gpu"

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120

  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 capabilities:,
                                 http_client:,
                                 options: browser_options)
end

Capybara.register_driver :iphone do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': { args: %w[headless disable-gpu disable-setuid-sandbox window-size=7680,4320 use-mobile-user-agent user-agent=iPhone] }
  )

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 capabilities:,
                                 http_client:)
end

Capybara.server = :webrick
Capybara.javascript_driver = :selenium_headless
Capybara.default_max_wait_time = 15
