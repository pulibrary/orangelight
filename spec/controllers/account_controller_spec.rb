# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountController do
  let(:valid_patron_response) { File.open(fixture_path + '/bibdata_patron_response.json') }
  let(:generic_voyager_account_response) { VoyagerAccount.new(fixture('/generic_voyager_account_response.xml')) }
  let(:generic_voyager_account_empty_response) { VoyagerAccount.new(fixture('/generic_voyager_account_empty_response.xml')) }
  let(:item_ids_to_cancel) { %w[42287 42289 69854 28010] }

  describe '#cancel_success' do
    subject(:account_controller) { described_class.new }
    it 'returns true when requested cancelled items are sucessfully deleted' do
      expect(account_controller.send(:cancel_success, item_ids_to_cancel.size, generic_voyager_account_empty_response, item_ids_to_cancel)).to be_truthy
    end

    it 'returns false when requested cancelled items are not successfully deleted' do
      expect(account_controller.send(:cancel_success, item_ids_to_cancel.size, generic_voyager_account_response, item_ids_to_cancel)).to be_falsey
    end
  end

  describe '#illiad_patron_client' do
    subject(:account_controller) { described_class.new }
    let(:outstanding_ill_requests_response) { File.open(fixture_path + '/outstanding_ill_requests_response.json') }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_voyager_response) { File.open(fixture_path + '/pul_voyager_account_response.xml').read }

    before do
      ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
      sign_in(valid_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      patron = account_controller.send(:current_patron?, valid_user.uid)
      outstanding_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Transaction/UserRequests/#{patron['netid']}?$filter=TransactionStatus%20ne%20'Cancelled%20by%20ILL%20Staff'"
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{patron['patron_id']}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_voyager_response, headers: {})
      stub_request(:get, outstanding_ill_requests_uri)
        .to_return(status: 200, body: outstanding_ill_requests_response, headers: {
                     'Accept' => 'application/json',
                     'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Apikey' => 'TESTME'
                   })
    end

    it 'Returns Non-canceled Illiad Transactions' do
      get :index
      expect(assigns(:illiad_transactions).size).to eq 2
    end
  end

  describe 'cancel_ill_requests' do
    subject(:account_controller) { described_class.new }
    let(:outstanding_ill_requests_response) { File.open(fixture_path + '/outstanding_ill_requests_response.json') }
    let(:cancel_ill_requests_response) { File.open(fixture_path + '/cancel_ill_requests_response.json') }
    let(:params_cancel_requests) { ['1093597'] }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_voyager_response) { File.open(fixture_path + '/pul_voyager_account_response.xml').read }

    before do
      ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
      sign_in(valid_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      patron = account_controller.send(:current_patron?, valid_user.uid)
      outstanding_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Transaction/UserRequests/#{patron['netid']}?$filter=TransactionStatus%20ne%20'Cancelled%20by%20ILL%20Staff'"
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{patron['patron_id']}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_voyager_response, headers: {})
      stub_request(:get, outstanding_ill_requests_uri)
        .to_return(status: 200, body: outstanding_ill_requests_response, headers: {
                     'Accept' => 'application/json',
                     'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                     'Apikey' => 'TESTME'
                   })
      cancel_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/transaction/#{params_cancel_requests[0]}/route"
      stub_request(:put, cancel_ill_requests_uri)
        .with(body: "{\"Status\":\"Cancelled by Customer\"}")
        .to_return(status: 200, body: cancel_ill_requests_response, headers: {
       	  'Content-Type'=>'application/json',
       	  'Apikey'=>'TESTME'
           })
    end

    it 'Cancels Illiad Transactions' do
      post :cancel_ill_requests, params: {cancel_requests: params_cancel_requests}, format: :js
      expect(flash.now[:success]).to eq I18n.t('blacklight.account.cancel_success')
    end
  end

  describe '#current_patron?' do
    subject(:account_controller) { described_class.new }
    let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
    let(:invalid_user) { FactoryBot.create(:invalid_princeton_patron) }
    let(:unauthorized_user) { FactoryBot.create(:unauthorized_princeton_patron) }

    it 'Returns Princeton Patron Account Data using a NetID' do
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})

      patron = account_controller.send(:current_patron?, valid_user.uid)
      expect(patron).to be_truthy
    end

    it "Returns false when an ID doesn't exist" do
      invalid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{invalid_user.uid}"
      stub_request(:get, invalid_patron_record_uri)
        .to_return(status: 404, body: '<html><title>Not Here</title><body></body></html>', headers: {})
      patron = account_controller.send(:current_patron?, invalid_user.uid)
      expect(patron).to be_falsey
    end

    it "Returns false when the application isn't authorized to access patron data" do
      unauthorized_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{unauthorized_user.uid}"
      stub_request(:get, unauthorized_patron_record_uri)
        .to_return(status: 403, body: '<html><title>Not Authorized</title><body></body></html>', headers: {})
      patron = account_controller.send(:current_patron?, unauthorized_user.uid)
      expect(patron).to be_falsey
    end

    it 'Returns false when the http response throws 500' do
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 500, body: 'Error', headers: {})
      patron = account_controller.send(:current_patron?, valid_user.uid)
      expect(patron).to be_falsey
    end
  end

  describe '#borrow_direct_redirect' do
    let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }
    let(:valid_barcode_user) { FactoryBot.create(:guest_patron) }
    let(:valid_cas_user) { FactoryBot.create(:valid_princeton_patron) }

    it 'Redirects to Borrow Direct for valid cas user' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      get :borrow_direct_redirect
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
    end
    it 'Redirect url includes query when param q is present' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      query = 'a book title'
      get :borrow_direct_redirect, params: { q: query }
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
      expect(response.location).to include('a%20book%20title')
    end
    # For interoperability with umlaut
    it 'Redirect url includes query when param query is present' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      query = 'a book title'
      get :borrow_direct_redirect, params: { query: query }
      expect(response.location).to match(%r{https:\/\/bd.relaisd2d.com\/})
      expect(response.location).to include('a%20book%20title')
    end
    it 'Redirects to CAS login page for non-logged in user' do
      get :borrow_direct_redirect
      expect(response.location).to match(user_cas_omniauth_authorize_path)
    end
    it 'Redirects to Home page for ineligible barcode only user' do
      sign_in(valid_barcode_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_barcode_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_patron_response, headers: {})
      get :borrow_direct_redirect
      expect(response).to redirect_to(root_url)
    end
  end

  describe '#voyager_account?' do
    subject(:account_controller) { described_class.new }
    let(:valid_voyager_response) { File.open(fixture_path + '/pul_voyager_account_response.xml').read }
    let(:valid_voyager_patron) { JSON.parse(valid_patron_response.read.to_s).with_indifferent_access }
    let(:invalid_voyager_patron) { JSON.parse('{ "patron_id": "foo" }').with_indifferent_access }
    let(:unauthorized_voyager_patron) { JSON.parse('{ "patron_id": "bar" }').with_indifferent_access }

    it 'Returns Voyager account data using a valid patron record' do
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: valid_voyager_response, headers: {})
      account = account_controller.send(:voyager_account?, valid_voyager_patron)
      expect(account).to be_truthy
      expect(account.doc).to be_a(Nokogiri::XML::Document)
    end

    it "Returns false when the patron record doesn't exist" do
      invalid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{invalid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, invalid_patron_record_uri)
        .to_return(status: 404, body: 'Account Not Found', headers: {})
      account = account_controller.send(:voyager_account?, invalid_voyager_patron)
      expect(account).to be_falsey
    end

    it "Returns false when the application isn't authorized to access Voyager account data" do
      unauthorized_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{unauthorized_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, unauthorized_patron_record_uri)
        .to_return(status: 403, body: 'Application Not Authorized', headers: {})
      account = account_controller.send(:voyager_account?, unauthorized_voyager_patron)
      expect(account).to be_falsey
    end
  end
end
