# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bibdata do
  describe '#holding_locations' do
    subject(:locations) { described_class.holding_locations }

    let(:response) { instance_double(Faraday::Response, status: status, body: body) }
    let(:status) { 200 }
    let(:body) { '[{"label":"African American Studies Reading Room","code":"aas","library":{"label":"Firestone Library","code":"firestone","order":1}}]' }

    before { allow(Faraday).to receive(:get).and_return(response) }
    context 'with a successful response from bibdata' do
      it 'returns the holdings location hash' do
        expect(locations).to include('aas')
      end
    end

    context 'with an unsuccessful response from bibdata' do
      let(:status) { 500 }

      before { Rails.cache.clear }

      it 'returns an empty hash' do
        expect(locations).to be_empty
      end
    end
  end

  describe '#hathi_access' do
    context 'with a successful response from bibdata' do
      it 'returns the holdings location hash' do
        body = '[{"oclc_number": "19774500","bibid": "1000066","status": "DENY","origin": "CUL"}]'
        stub_request(:get, "#{ENV['bibdata_base']}/hathi/access?oclc=19774500")
          .to_return(status: 200, body: body)
        expect(described_class.hathi_access("19774500")).to eq(
          [
            {
              "oclc_number" => "19774500",
              "bibid" => "1000066",
              "status" => "DENY",
              "origin" => "CUL"
            }
          ]
        )
      end
    end

    context 'with an unsuccessful response from bibdata' do
      it 'returns an empty hash' do
        stub_request(:get, "#{ENV['bibdata_base']}/hathi/access?oclc=19774500")
          .to_return(status: 404)
        expect(described_class.hathi_access("19774500")).to be_empty
      end
    end
  end
end
