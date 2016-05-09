require 'coveralls'
require 'capybara/poltergeist'
require 'webmock/rspec'
require 'factory_girl'

# allow connections to localhost, umlaut and bibdata marc record service
WebMock.disable_net_connect!(allow_localhost: true, allow: [(ENV['umlaut_base']).to_s, /\/bibliographic\//, /\/locations\//])

Coveralls.wear!('rails') do
  add_filter '/lib/orangelight/browse_lists.rb'
  add_filter '/app/models/orangelight.rb'
end

$in_travis = !ENV['TRAVIS'].nil? && ENV['TRAVIS'] == 'true'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60)
end
Capybara.javascript_driver = :poltergeist
