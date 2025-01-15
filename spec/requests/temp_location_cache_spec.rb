# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::TempLocationCache do
  describe 'retrieve' do
    it 'gets the data from a bibdata request' do
      bibdata_stub = stub_temp_location_request
      cache = described_class.new

      cache.retrieve 'RES_SHARE$OUT_RS_REQ'

      expect(bibdata_stub).to have_been_requested
    end
    it 'returns a hash of data' do
      stub_temp_location_request
      cache = described_class.new

      expect(cache.retrieve('RES_SHARE$OUT_RS_REQ')[:label]).to eq('Borrowing Resource Sharing Requests')
    end
    context 'when the specific temp location is requested multiple times' do
      it 'sends only one request to bibdata' do
        bibdata_stub = stub_temp_location_request
        cache = described_class.new

        3.times { cache.retrieve 'RES_SHARE$OUT_RS_REQ' }

        expect(bibdata_stub).to have_been_requested.times(1)
      end
      it 'returns a hash of data' do
        stub_temp_location_request
        cache = described_class.new

        3.times do
          expect(cache.retrieve('RES_SHARE$OUT_RS_REQ')[:label]).to eq('Borrowing Resource Sharing Requests')
        end
      end
    end
  end
end

def stub_temp_location_request
  stub_request(:get, 'https://bibdata-staging.lib.princeton.edu/locations/holding_locations/RES_SHARE$OUT_RS_REQ.json')
    .to_return(body: '{"label":"Borrowing Resource Sharing Requests","code":"RES_SHARE$OUT_RS_REQ","aeon_location":false,"recap_electronic_delivery_location":false,"open":true,"requestable":true,"always_requestable":false,"circulates":true,"remote_storage":"","fulfillment_unit":"RES_FU","library":{"label":"Resource Sharing Library","code":"RES_SHARE","order":0},"holding_library":null,"delivery_locations":[]}')
end
