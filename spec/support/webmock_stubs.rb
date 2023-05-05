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

def stub_availability_by_holding_id(bib_id:, holding_id:, body: true)
  url = "#{Requests.config['bibdata_base']}/bibliographic/#{bib_id}/holdings/#{holding_id}/availability.json"
  if body == false
    stub_request(:get, url)
      .to_return(status: 200)
  else
    file_path = File.join(fixture_path, 'availability', 'by_holding_id', "#{bib_id}_#{holding_id}.json")
    stub_request(:get, url)
      .to_return(status: 200, body: File.read(file_path))
  end
end

def stub_catalog_raw(bib_id:, type: nil, body: true)
  url = "#{Requests::Config[:pulsearch_base]}/catalog/#{bib_id}/raw"
  return stub_request(:get, url).to_return(status: 200, body: {}.to_json) if body == false
  file_path = if type
                File.join(fixture_path, 'raw', type, "#{bib_id}.json")
              else
                File.join(fixture_path, 'raw', "#{bib_id}.json")
              end
  stub_request(:get, url)
    .to_return(status: 200, body: File.read(file_path))
end
