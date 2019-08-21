# frozen_string_literal: true

def stub_holding_locations
  stub_request(:get, "#{ENV['bibdata_base']}/locations/holding_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'holding_locations.json')))
end

def stub_test_document
  stub_request(:get, "#{ENV['bibdata_base']}/bibliographic/test-id")
    .to_return(status: 200, body: '')
end
