require 'rails_helper'

describe Requests::BibdataService do
  describe '.connection' do
    it 'returns a Faraday connection' do
      expect(described_class.connection).to be_a Faraday::Connection
    end
  end

  describe '.delivery_locations' do
    let(:locations) { described_class.delivery_locations }

    context 'with a successful response from bibdata' do
      it 'returns the holdings location hash' do
        stub_delivery_locations
        expect(locations['QX']['label']).to eq "Firestone Circulation Desk"
      end
    end

    context 'with an unsuccessful response from bibdata' do
      it 'returns an empty hash' do
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/delivery_locations.json")
          .to_return(status: 500, body: 'failure', headers: {})
        expect(locations).to be_empty
      end
    end
  end
end
