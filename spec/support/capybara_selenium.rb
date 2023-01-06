# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/rspec'
require "selenium-webdriver"

Capybara.register_driver(:selenium) do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': { args: %w[headless disable-gpu disable-setuid-sandbox window-size=7680,4320] }
  )

  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--headless"
  browser_options.args << "--disable-gpu"
  browser_options.args << "--window-size=1920,1200"

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

Capybara.javascript_driver = :selenium
