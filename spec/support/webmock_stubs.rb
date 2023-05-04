# frozen_string_literal: true

def stub_holding_locations
  stub_request(:get, "#{Requests.config['bibdata_base']}/locations/holding_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'holding_locations.json')))
end

def stub_alma_holding_locations
  stub_request(:get, "#{Requests.config['bibdata_base']}/locations/holding_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'alma', 'holding_locations.json')))
end

def stub_single_holding_location(location_code)
  file_path = File.join(fixture_path, 'holding_locations', "#{location_code.tr('$', '_')}.json")
  stub_request(:get, "#{Requests.config['bibdata_base']}/locations/holding_locations/#{location_code}.json")
    .to_return(status: 200, body: File.read(file_path))
end

def stub_test_document
  stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/test-id")
    .to_return(status: 200, body: '')
end
