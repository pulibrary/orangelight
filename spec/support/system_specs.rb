# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    if ENV["RUN_IN_BROWSER"]
      driven_by(:selenium_chrome)
    else
      driven_by(:selenium_chrome_headless)
    end
  end
  config.before(:each, type: :system, js: true, in_browser: true) do
    driven_by(:selenium_chrome)
  end
end
