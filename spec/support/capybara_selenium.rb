# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/rspec'
require "selenium-webdriver"

# The default HeadlessChrome user agent is detected to be a bot by the Voight-Kampff
# gem, this user agent string is for a human-propelled Microsoft Edge instead
HUMAN_USER_AGENT = '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59'

Capybara.register_driver(:selenium) do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << "--headless" unless ENV['RUN_IN_BROWSER']
  browser_options.args << "--disable-gpu"
  browser_options.args << "--disable-setuid-sandbox"
  browser_options.args << "--window-size=1920,1200"
  browser_options.args << "--user-agent=#{HUMAN_USER_AGENT}"

  http_client = Selenium::WebDriver::Remote::Http::Default.new
  http_client.read_timeout = 120
  http_client.open_timeout = 120

  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
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

Capybara.register_driver :selenium_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless=new')
    opts.add_argument('--disable-gpu')
    opts.add_argument('--window-size=1920,1200')
    opts.add_argument("--user-agent=#{HUMAN_USER_AGENT}")
  end
  Capybara::Selenium::Driver.new(app, **{ :browser => :chrome, options_key => browser_options })
end

Capybara.javascript_driver = :selenium
