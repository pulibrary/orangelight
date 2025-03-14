# frozen_string_literal: true
require 'rails_helper'

describe Requests::Patron, requests: true, patrons: true do
  subject(:patron) do
    described_class.new(user:, patron_hash: patron_values)
  end
  let(:first_name) { "Test" }
  let(:patron_values) do
    {
      first_name:
    }
  end
  let(:uid) { 'foo' }
  let(:guest?) { false }
  let(:provider) { nil }
  let(:user) do
    instance_double(User, guest?: guest?, uid:, alma_provider?: false, provider:, valid?: true)
  end
  let(:bibdata_uri) { Requests.config[:bibdata_base] }
  let(:valid_patron_response) { file_fixture('../bibdata_patron_response.json') }
  let(:valid_barcode_patron_response) { file_fixture('../bibdata_patron_response_barcode.json') }
  let(:invalid_patron_response) { file_fixture('../bibdata_not_found_patron_response.json') }

  context 'when the user is provided from Alma' do
    let(:uid) { 'BC123456789' }
    let(:user) do
      instance_double(User, guest?: guest?, uid:, alma_provider?: true, provider:)
    end
    let(:patron_with_multiple_barcodes) { file_fixture('../BC123456789.json') }

    before do
      stub_request(:get, "https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/#{uid}?expand=fees,requests,loans")
        .to_return(status: 200, body: patron_with_multiple_barcodes, headers: { "Content-Type" => "application/json" })
    end

    it 'creates a patron with the active barcode' do
      patron = described_class.new(user:)
      expect(patron.barcode).to eq('77777777')
    end
  end

  context 'A user with a valid princeton net id patron record' do
    describe '#patron' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true")
          .to_return(status: 200, body: valid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user:)
        expect(patron).to be_truthy
        expect(patron.active_email).to eq('a@b.com')
        expect(patron.netid).to eq('jstudent')
        expect(patron.telephone).to eq('111-222-3333')
        expect(patron.status).to eq('student')
        expect(patron.pustatus).to eq('undergraduate')
        expect(patron.eligible_for_library_services?).to be_truthy
      end
    end
  end
  context 'A user with a valid barcode patron record' do
    describe '#current_patron_hash' do
      let(:provider) { 'cas' }
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true")
          .to_return(status: 200, body: valid_barcode_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user:)
        expect(patron).to be_truthy
        expect(patron.active_email).to eq('a@b.com')
        expect(patron.netid).to be_nil
        expect(patron.eligible_for_library_services?).to be_truthy
      end
    end
  end
  context 'A user with a netid that does not have a matching patron record' do
    describe '#current_patron_hash' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true")
          .to_return(status: 404, body: invalid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user:)
        expect(patron.errors).to eq(["A problem occurred looking up your library account."])
      end
    end
  end
  context 'Cannot connect to Patron Data service' do
    describe '#current_patron_hash' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true")
          .to_return(status: 403, body: invalid_patron_response, headers: {})
      end
      it 'Handles an authorized princeton net ID holder' do
        patron = described_class.new(user:)
        expect(patron.errors).to eq(["A problem occurred looking up your library account."])
      end
    end
  end
  context 'System Error from Patron data service' do
    describe '#current_patron_hash' do
      before do
        stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true")
          .to_return(status: 500, body: invalid_patron_response, headers: {})
      end
      it 'cannot return a patron record' do
        patron = described_class.new(user:)
        expect(patron.errors).to eq(["A problem occurred looking up your library account."])
      end
    end
  end
  context 'when the HTTP request threshold error is raised for the BibData API' do
    describe '#current_patron_hash' do
      let(:patron_values) { nil }

      before do
        stub_request(
          :get,
          "#{bibdata_uri}/patron/#{uid}?ldap=true"
        ).to_return(
          status: 429
        )
      end

      it 'raises an error' do
        expect { patron.errors }.to raise_error(Bibdata::PerSecondThresholdError)
      end
    end
  end
  context 'when unable to connect to bibdata' do
    before do
      allow(Faraday).to receive(:get).with("#{bibdata_uri}/patron/foo?ldap=true")
                                     .and_raise(Faraday::ConnectionFailed, 'execution expired')
    end

    it 'logs the error' do
      allow(Rails.logger).to receive(:error)
      described_class.new(user:)
      expect(Rails.logger).to have_received(:error).with("Unable to connect to #{bibdata_uri}")
    end
  end
  context 'when bibdata passes on an html response' do
    let(:patron_url) { "#{bibdata_uri}/patron/#{uid}?ldap=true" }
    before do
      stub_request(
        :get,
        patron_url
      ).to_return(
        status: 200,
        body: '<html><head<title>Request Rejected</title></head><html>',
        headers: { "Content-Type" => "application/json" }
      )
    end
    it 'logs the error' do
      allow(Rails.logger).to receive(:error)
      described_class.new(user:)
      expect(Rails.logger).to have_received(:error).with("#{patron_url} returned an invalid patron response: <html><head<title>Request Rejected</title></head><html>")
    end
  end
  context 'when bibdata passes on an empty response' do
    before do
      stub_request(
        :get,
        "#{bibdata_uri}/patron/#{uid}?ldap=true"
      ).to_return(
        status: 200,
        body: '',
        headers: { "Content-Type" => "application/json" }
      )
    end
    it 'logs the error' do
      allow(Rails.logger).to receive(:error)
      described_class.new(user:)
      expect(Rails.logger).to have_received(:error).with("#{bibdata_uri}/patron/foo?ldap=true returned an empty patron response")
    end
  end
  context 'Passing in patron information instead of loading it from bibdata' do
    it "does not call to bibdata" do
      patron = described_class.new(user: instance_double(User, guest?: false, uid: 'foo'), patron_hash: { barcode: "1234567890" })
      expect(patron.barcode).to eq('1234567890')
    end
  end

  describe '#first_name' do
    it "accesses the first name passed in the API values" do
      expect(patron.first_name).to eq(first_name)
    end

    context "when loading the patron data from the LDAP server" do
      let(:givenname) { 'LDAP' }
      let(:ldap) do
        {
          givenname:
        }
      end
      let(:patron_values) do
        {
          ldap:
        }
      end

      it "accesses the first name passed in the LDAP attributes" do
        expect(patron.first_name).to eq(givenname)
      end
    end
  end
end
