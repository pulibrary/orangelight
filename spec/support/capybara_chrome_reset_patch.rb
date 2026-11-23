# frozen_string_literal: true

require 'capybara/selenium/driver'

# Capybara 3.40.0 (the latest release) clears browser storage between examples with
#   execute_cdp('Storage.clearDataForOrigin', origin: '*', ...)
# Chrome 158+ rejects the '*' wildcard ("invalid argument: * is not a valid URL"),
# which makes Capybara.reset_sessions! raise after every example.
# When that happens, clear all cookies and the app server's storage explicitly instead.
# Remove this once Capybara ships a fix.
module CapybaraChromeResetPatch
  def execute_cdp(cmd, params = {})
    super
  rescue ::Selenium::WebDriver::Error::InvalidArgumentError
    raise unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    storage_types = params[:storageTypes].to_s.split(',') - ['cookies']
    base_url = Capybara.current_session.server&.base_url
    return if storage_types.empty? || base_url.nil?

    super('Storage.clearDataForOrigin', { origin: base_url, storageTypes: storage_types.join(',') })
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetPatch)
