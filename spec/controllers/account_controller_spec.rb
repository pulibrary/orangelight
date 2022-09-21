# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountController do
  let(:valid_patron_response) { File.open(fixture_path + '/bibdata_patron_response.json') }
  let(:campus_authorized_patron) { File.open(fixture_path + '/bibdata_patron_auth_response.json') }
  let(:campus_unauthorized_patron) { File.open(fixture_path + '/bibdata_patron_unauth_response.json') }
  let(:campus_trained_patron) { File.open(fixture_path + '/bibdata_patron_trained_response.json') }
  let(:outstanding_ill_requests_response) { File.open(fixture_path + '/outstanding_ill_requests_response.json') }
  let(:verify_user_response) { File.open(fixture_path + '/ill_verify_user_response.json') }
  let(:current_illiad_user_uri) { "#{Requests::Config[:illiad_api_base]}/ILLiadWebPlatform/Users/jstudent" }
  before do
    current_ill_requests_uri = "#{Requests::Config[:illiad_api_base]}/ILLiadWebPlatform/Transaction/UserRequests/jstudent?$filter=" \
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
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
    end

    it 'Returns Non-canceled Illiad Transactions' do
      get :borrow_direct_redirect
      expect(assigns(:illiad_transactions).size).to eq 2
    end

    context "barcode user" do
      let(:valid_user) { FactoryBot.create(:guest_patron) }

      it 'Returns no Illiad Transactions' do
        get :borrow_direct_redirect
        expect(assigns(:illiad_transactions).size).to eq 0
      end
    end

    context "alma user" do
      let(:valid_user) { FactoryBot.create(:alma_patron) }

      it 'Returns no Illiad Transactions' do
        get :borrow_direct_redirect
        expect(assigns(:illiad_transactions).size).to eq 0
      end
    end

    context "cas user with no illiad account" do
      it 'Returns no Illiad Transactions' do
        stub_request(:get, current_illiad_user_uri)
          .to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
        get :borrow_direct_redirect
        expect(assigns(:illiad_transactions).size).to eq 0
      end
    end
  end

  describe 'cancel_ill_requests' do
    subject(:account_controller) { described_class.new }
    let(:cancel_ill_requests_response) { File.open(fixture_path + '/cancel_ill_requests_response.json') }
    let(:params_cancel_requests) { ['1093597'] }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }

    before do
      sign_in(valid_user)
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}"
      cancel_ill_requests_uri = "#{Requests::Config[:illiad_api_base]}/ILLiadWebPlatform/transaction/#{params_cancel_requests[0]}/route"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      stub_request(:put, cancel_ill_requests_uri)
        .with(body: "{\"Status\":\"Cancelled by Customer\"}")
        .to_return(status: 200, body: cancel_ill_requests_response, headers: {
                     'Content-Type' => 'application/json',
                     'Apikey' => 'TESTME'
                   })
    end

    context 'with a canceled transaction' do
      it 'Cancels Illiad Transactions' do
        post :cancel_ill_requests, params: { cancel_requests: params_cancel_requests }, format: :js
        expect(flash.now[:success]).to eq I18n.t('blacklight.account.cancel_success')
      end
    end

    context 'with no cancel_requests parameter' do
      it 'flashes an error message' do
        post :cancel_ill_requests, format: :js
        expect(flash.now[:error]).to eq I18n.t('blacklight.account.cancel_no_items')
      end
    end

    context 'the response contains an error' do
      let(:cancel_ill_requests_response) { File.open(fixture_path + '/cancel_ill_requests_failed_response.json') }
      it 'flashes an error message' do
        post :cancel_ill_requests, params: { cancel_requests: params_cancel_requests }, format: :js
        expect(flash.now[:error]).to eq I18n.t('blacklight.account.cancel_fail')
      end
    end
  end

  describe '#current_patron' do
    subject(:account_controller) { described_class.new }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
    let(:invalid_user) { FactoryBot.create(:invalid_princeton_patron) }
    let(:unauthorized_user) { FactoryBot.create(:unauthorized_princeton_patron) }

    it 'returns Princeton Patron Account Data using a persisted User Model' do
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})

      patron = account_controller.send(:current_patron, valid_user)
      expect(patron).to be_truthy
    end

    it "returns a nil value when a user ID cannot be resolved to a persisted User Model" do
      invalid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{invalid_user.uid}"
      stub_request(:get, invalid_patron_record_uri)
        .to_return(status: 404, body: '<html><title>Not Here</title><body></body></html>', headers: {})
      patron = account_controller.send(:current_patron, invalid_user)
      expect(patron).to be nil
    end

    it "returns a nil value when the application isn't authorized to access patron data" do
      unauthorized_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{unauthorized_user.uid}"
      stub_request(:get, unauthorized_patron_record_uri)
        .to_return(status: 403, body: '<html><title>Not Authorized</title><body></body></html>', headers: {})
      patron = account_controller.send(:current_patron, unauthorized_user)
      expect(patron).to be nil
    end

    it 'returns a nil value when the HTTP response to the API request has a 500 status code' do
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 500, body: 'Error', headers: {})
      patron = account_controller.send(:current_patron, valid_user)
      expect(patron).to be nil
    end
  end

  describe '#borrow_direct_redirect' do
    let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }
    let(:valid_alma_user) { FactoryBot.create(:alma_patron) }
    let(:valid_cas_user) { FactoryBot.create(:valid_princeton_patron) }

    it 'Redirects to Borrow Direct for valid cas user authorized to be on campus' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: campus_authorized_patron, headers: {})
      get :borrow_direct_redirect
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
    end
    it 'Redirects to Borrow Direct for valid cas user who has taken training to be on campus' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: campus_trained_patron, headers: {})
      get :borrow_direct_redirect
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
    end

    it 'Redirect url includes query when param q is present' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: campus_authorized_patron, headers: {})
      query = 'a book title'
      get :borrow_direct_redirect, params: { q: query }
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
      expect(response.location).to include('a%20book%20title')
    end
    # For interoperability with umlaut
    it 'Redirect url includes query when param query is present' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: campus_authorized_patron, headers: {})
      query = 'a book title'
      get :borrow_direct_redirect, params: { query: query }
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
      expect(response.location).to include('a%20book%20title')
    end
    it 'Redirects to CAS login page for non-logged in user' do
      get :borrow_direct_redirect
      expect(response.location).to match(user_cas_omniauth_authorize_path)
    end
    it 'Redirects to Home page for ineligible alma user' do
      sign_in(valid_alma_user)
      get :borrow_direct_redirect
      expect(response).to redirect_to(root_url)
    end
  end
end
