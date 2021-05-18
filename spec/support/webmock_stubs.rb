# frozen_string_literal: true

def stub_holding_locations
  stub_request(:get, "#{Requests.config['bibdata_base']}/locations/holding_locations.json")
    .to_return(status: 200,
               body: File.read(File.join(fixture_path, 'bibdata', 'holding_locations.json')))
end

def stub_test_document
  stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/test-id")
    .to_return(status: 200, body: '')
end

def stub_hathi
  stub_request(:get, %r{https://catalog.hathitrust.org/api/volumes/brief/})
    .to_return(body: '{ "records": {}, "items": [] }', status: 200)

  stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/oclc/42579288.json")
    .to_return(body: File.new('spec/fixtures/hathi_42579288.json'), status: 200)

  stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/isbn/1576070751.json")
    .to_return(body: File.new('spec/fixtures/hathi_42579288.json'), status: 200)

  stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/lccn/99047618.json")
    .to_return(body: File.new('spec/fixtures/hathi_42579288.json'), status: 200)

  stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/oclc/1586310.json")
    .to_return(body: File.new('spec/fixtures/hathi_1586310.json'), status: 200)

  stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/oclc/53849218.json")
    .to_return(body: File.new('spec/fixtures/hathi_17024346.json'), status: 200)

  stub_request(:get, "https://catalog.hathitrust.org/api/volumes/brief/oclc/3280195.json")
    .to_return(body: File.new('spec/fixtures/hathi_3280195.json'), status: 200)
end
