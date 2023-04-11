# frozen_string_literal: true
require 'rails_helper'

describe Requests::Scsb do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:patron) do
    Requests::Patron.new(user:, session: {}, patron: valid_patron)
  end
  let(:scsb_no_format) { fixture('/SCSB-7935196.json') }
  let(:location_code) { 'scsbnypl' }
  let(:params) do
    {
      system_id: 'SCSB-7935196',
      source: 'pulsearch',
      mfhd: nil,
      patron:
    }
  end
  let(:request_scsb) { Requests::Request.new(**params) }
  let(:first_item) { request_scsb.holdings["8076325"]["items"][0] }
  let(:second_item) { request_scsb.holdings["8076325"]["items"][1] }

  context 'with an authorized scsb key', vcr: { cassette_name: 'authorized_ol_authorized_bibdata_scsb_key', record: :none } do
    it 'is available' do
      stub_scsb_availability(bib_id: ".b106574619", institution_id: "NYPL", barcode: "33433088591924")
      expect(first_item["barcode"]).to eq('33433088591924')
      expect(first_item["status_at_load"]).to eq("Available")
      expect(first_item[:status_label]).to be_nil
      expect(first_item["status_label"]).to eq("Available")
      expect(request_scsb.requestable[0].status).to eq("Available")

      expect(second_item["barcode"]).to eq("33433088591932")
    end

    context 'when a Princeton item has not made it into SCSB yet' do
      let(:bibdata_availability_url) { 'https://bibdata-staging.princeton.edu/bibliographic/99122304923506421/holdings/22511126440006421/availability.json' }
      let(:bibdata_availability_response) do
        '[{"barcode":"32101112612526","id":"23511126430006421","holding_id":"22511126440006421","copy_number":"0","status":"Available","status_label":"Item in place","status_source":"base_status","process_type":null,"on_reserve":"N","item_type":"Gen","pickup_location_id":"recap","pickup_location_code":"recap","location":"recap$pa","label":"ReCAP - Remote Storage","description":"","enum_display":"","chron_display":"","in_temp_library":false}]'
      end
      let(:params) do
        {
          system_id: '99122304923506421',
          source: 'pulsearch',
          mfhd: nil,
          patron:
        }
      end
      let(:holding_location_info) { File.open('spec/fixtures/bibdata/recap_pa_holding_locations.json') }
      let(:first_item) { request_scsb.items['22511126440006421'].first }

      before do
        stub_scsb_availability(bib_id: "99122304923506421", institution_id: "PUL", barcode: nil, item_availability_status: nil, error_message: "Bib Id doesn't exist in SCSB database.")
        stub_request(:get, bibdata_availability_url)
          .to_return(status: 200, body: bibdata_availability_response)
        stub_request(:get, 'https://catalog.princeton.edu/catalog/99122304923506421/raw')
          .to_return(status: 200, body: File.read('spec/fixtures/raw_99122304923506421.json'))
        stub_request(:get, 'https://bibdata-staging.princeton.edu/locations/holding_locations/recap$pa.json')
          .to_return(status: 200, body: holding_location_info)
      end

      it 'is in process' do
        request_scsb
        expect(first_item["barcode"]).to eq('32101112612526')
        expect(first_item[:status_label]).to eq('In Process')
        expect(first_item["status_label"]).to eq('In Process')
        expect(first_item["status"]).to eq('Available')
        expect(request_scsb.requestable[0].status).to eq("Available")
      end
    end
  end
  context 'with an unauthorized scsb key', vcr: { cassette_name: 'unauthorized_ol_authorized_bibdata_scsb_key', record: :none } do
    before do
      stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .with(body: "{\"bibliographicId\":\".b106574619\",\"institutionId\":\"NYPL\"}")
        .and_return(status: 401, body: 'Authentication Failed')
    end
    it 'is not available' do
      allow(Rails.logger).to receive(:error)
      expect(first_item["barcode"]).to eq('33433088591924')
      expect(first_item["status_at_load"]).to eq("Available")
      expect(first_item[:status_label]).to eq("Unavailable")
      expect(first_item["status_label"]).to be_nil
      expect(request_scsb.requestable[0].status).to eq("Unavailable")

      expect(second_item["barcode"]).to eq("33433088591932")
      expect(Rails.logger).to have_received(:error).with("The request to the SCSB server failed: Authentication Failed")
    end
  end
end
