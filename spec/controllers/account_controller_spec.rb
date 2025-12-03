# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountController, patrons: true do
  let(:valid_patron_response) { File.open('spec/fixtures/bibdata_patron_response.json') }
  let(:outstanding_ill_requests_response) { File.open('spec/fixtures/outstanding_ill_requests_response.json') }
  let(:verify_user_response) { File.open('spec/fixtures/ill_verify_user_response.json') }
  let(:current_illiad_user_uri) { "#{Requests.config[:illiad_api_base]}/ILLiadWebPlatform/Users/jstudent" }
  before do
    current_ill_requests_uri = "#{Requests.config[:illiad_api_base]}/ILLiadWebPlatform/Transaction/UserRequests/jstudent?$filter=" \
      "ProcessType%20eq%20'Borrowing'%20and%20TransactionStatus%20ne%20'Request%20Finished'%20and%20not%20startswith%28TransactionStatus,'Cancelled'%29"
    stub_request(:get, current_ill_requests_uri)
      .to_return(status: 200, body: outstanding_ill_requests_response, headers: {
                   'Accept' => 'application/json',
                   'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                   'Apikey' => 'TESTME'
                 })
    stub_request(:get, current_illiad_user_uri)
      .to_return(status: 200, body: verify_user_response)
  end

  describe '#digitization_requests' do
    context 'when Orangelight is in read only mode' do
      before do
        allow(Orangelight).to receive(:read_only_mode).and_return(true)
      end

      it 'redirects to root and flashes an explanatory message' do
        get :digitization_requests
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Account login unavailable during maintenace.")
      end
    end
  end

  describe '#illiad_patron_client' do
    subject(:account_controller) { described_class.new }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }

    before do
      sign_in(valid_user)
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}?ldap=false"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
    end

    it 'Returns Non-canceled Illiad Transactions' do
      get :digitization_requests
      expect(assigns(:illiad_transactions).size).to eq 2
    end

    context "alma user" do
      let(:valid_user) { FactoryBot.create(:alma_patron) }

      it 'Returns no Illiad Transactions' do
        get :digitization_requests
        expect(assigns(:illiad_transactions).size).to eq 0
      end
    end

    context "cas user without an illiad account" do
      it 'Returns no Illiad Transactions' do
        stub_request(:get, current_illiad_user_uri)
          .to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
        get :digitization_requests
        expect(assigns(:illiad_transactions).size).to eq 0
      end
    end
  end

  describe '#current_patron' do
    subject(:account_controller) { described_class.new }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
    let(:invalid_user) { FactoryBot.create(:invalid_princeton_patron) }
    let(:unauthorized_user) { FactoryBot.create(:unauthorized_princeton_patron) }

    it 'returns Princeton Patron Account Data for a patron with a net ID in Alma' do
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}?ldap=false"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})

      patron = account_controller.send(:current_patron, valid_user)
      expect(patron).to be_truthy
    end

    it "returns an empty value when a patron net ID cannot be resolved to a net ID stored in Alma" do
      invalid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{invalid_user.uid}"
      stub_request(:get, invalid_patron_record_uri)
        .to_return(status: 404, body: '<html><title>Not Here</title><body></body></html>', headers: {})
      patron = account_controller.send(:current_patron, invalid_user)
      expect(patron).to eq({})
    end

    it "returns an empty value when the machine Orangelight is running on isn't authorized to access patron data" do
      unauthorized_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{unauthorized_user.uid}"
      stub_request(:get, unauthorized_patron_record_uri)
        .to_return(status: 403, body: '<html><title>Not Authorized</title><body></body></html>', headers: {})
      patron = account_controller.send(:current_patron, unauthorized_user)
      expect(patron).to eq({})
    end

    it 'returns an empty value when the HTTP response to the API request has a 500 status code' do
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 500, body: 'Error', headers: {})
      patron = account_controller.send(:current_patron, valid_user)
      expect(patron).to eq({})
    end
  end
end
