# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    Webdrivers::Chromedriver.required_version = "114.0.5735.90"
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    Webdrivers::Chromedriver.required_version = "114.0.5735.90"
    if ENV["RUN_IN_BROWSER"]
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end
  config.before(:each, type: :system, js: true, in_browser: true) do
    Webdrivers::Chromedriver.required_version = "114.0.5735.90"
    driven_by(:selenium_chrome)
  end
end
