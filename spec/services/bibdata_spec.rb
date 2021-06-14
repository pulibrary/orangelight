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
        stub_request(:get, "#{Requests.config['bibdata_base']}/hathi/access?oclc=19774500")
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
        stub_request(:get, "#{Requests.config['bibdata_base']}/hathi/access?oclc=19774500")
          .to_return(status: 404)
        expect(described_class.hathi_access("19774500")).to be_empty
      end
    end
  end

  describe '.get_patron' do
    subject(:patron) { described_class.get_patron(patron_user) }

    let(:patron_user) { User.create(username: "bbird", uid: "bbird") }
    let(:patron_valid) { patron_user.valid? }
    let(:headers) do
      {
        'Content-Type': 'application/json'
      }
    end
    let(:body) do
      {
        netid: "bbird",
        first_name: "Big",
        last_name: "Bird",
        barcode: "00000000000000",
        university_id: "100000000",
        patron_id: "100000000",
        patron_group: "staff",
        patron_group_desc: "P Faculty & Professional",
        requests_total: 0,
        loans_total: 0,
        fees_total: 0.0,
        active_email: "bbird@SCRUBBED_princeton.edu",
        campus_authorized: false,
        campus_authorized_category: "none"
      }
    end
    let(:headers) do
      {
        'Content-Type': 'application/json'
      }
    end
    let(:response) { instance_double(Faraday::Response, headers: headers, status: status, body: JSON.generate(body)) }

    before { allow(Faraday).to receive(:get).and_return(response) }

    context 'with a successful response from the bibdata endpoint' do
      let(:status) { 200 }

      it 'returns the patron user data' do
        expect(patron.symbolize_keys).to include(body)
        expect(patron.symbolize_keys).to include(valid: true)
      end
    end

    context 'when a server failure is encountered requesting the patron data from the bibdata endpoint' do
      let(:logger) { instance_double(ActiveSupport::Logger) }
      let(:status) { 500 }

      before do
        allow(logger).to receive(:error)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'returns a nil value and logs a message' do
        expect(patron).to be nil
        expect(logger).to have_received(:error).with("An error was encountered with the Patron Data Service.")
      end
    end

    context 'when the maximum number of HTTP requests transmitted to the Alma API endpoint is exceeded' do
      let(:logger) { instance_double(ActiveSupport::Logger) }
      let(:status) { 429 }

      before do
        allow(logger).to receive(:error)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'raises an error and logs a message' do
        expect { patron }.to raise_error(Bibdata::PerSecondThresholdError)
        expect(logger).to have_received(:error).with("The maximum number of HTTP requests per second for the Alma API has been exceeded.")
      end
    end

    context 'when a patron cannot be found for the given patron ID' do
      let(:logger) { instance_double(ActiveSupport::Logger) }
      let(:status) { 404 }

      before do
        allow(logger).to receive(:error)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'returns a nil value and logs a message' do
        expect(patron).to be nil
        expect(logger).to have_received(:error).with("404 Patron bbird cannot be found in the Patron Data Service.")
      end
    end

    context 'when a client is not authorized to request the patron data' do
      let(:logger) { instance_double(ActiveSupport::Logger) }
      let(:status) { 403 }

      before do
        allow(logger).to receive(:error)
        allow(Rails).to receive(:logger).and_return(logger)
      end

      it 'returns a nil value and logs a message' do
        expect(patron).to be nil
        expect(logger).to have_received(:error).with("403 Not Authorized to Connect to Patron Data Service at #{Requests.config['bibdata_base']}/patron/bbird")
      end
    end
  end
end
