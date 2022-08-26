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
    Requests::Patron.new(user: user, session: {}, patron: valid_patron)
  end
  let(:scsb_no_format) { fixture('/SCSB-7935196.json') }
  let(:location_code) { 'scsbnypl' }
  let(:params) do
    {
      system_id: 'SCSB-7935196',
      source: 'pulsearch',
      mfhd: nil,
      patron: patron
    }
  end
  let(:request_scsb) { Requests::Request.new(params) }
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
      expect(first_item[:status_label]).to eq("Not Available")
      expect(first_item["status_label"]).to be_nil
      expect(request_scsb.requestable[0].status).to eq("Not Available")

      expect(second_item["barcode"]).to eq("33433088591932")
      expect(Rails.logger).to have_received(:error).with("The request to the SCSB server failed: Authentication Failed")
    end
  end
end
