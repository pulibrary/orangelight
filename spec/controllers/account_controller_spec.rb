require 'rails_helper'

RSpec.describe AccountController do
  let(:valid_patron_response) { File.open(fixture_path + '/bibdata_patron_response.json') }
  let(:generic_voyager_account_response) { VoyagerAccount.new(fixture('/generic_voyager_account_response.xml')) }
  let(:generic_voyager_account_empty_response) { VoyagerAccount.new(fixture('/generic_voyager_account_empty_response.xml')) }
  let(:item_ids_to_cancel) { %w(42287 42289 69854 28010) }
  describe '#cancel_success' do
    it 'returns true when requested cancelled items are sucessfully deleted' do
      expect(subject.send(:cancel_success, item_ids_to_cancel.size, generic_voyager_account_empty_response, item_ids_to_cancel)).to be_truthy
    end

    it 'returns false when requested cancelled items are not successfully deleted' do
      expect(subject.send(:cancel_success, item_ids_to_cancel.size, generic_voyager_account_response, item_ids_to_cancel)).to be_falsey
    end
  end

  describe '#patron_account?' do
    let(:valid_user) { FactoryGirl.create(:valid_princeton_patron) }
    let(:invalid_user) { FactoryGirl.create(:invalid_princeton_patron) }
    let(:unauthorized_user) { FactoryGirl.create(:unauthorized_princeton_patron) }
    it 'Returns Princeton Patron Account Data using a NetID' do
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: valid_patron_response, headers: {})

      patron = subject.send(:current_patron?, valid_user.uid)
      expect(patron).to be_truthy
    end

    it "Returns false when an ID doesn't exist" do
      invalid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{invalid_user.uid}"
      stub_request(:get, invalid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 404, body: '<html><title>Not Here</title><body></body></html>', headers: {})
      patron = subject.send(:current_patron?, invalid_user.uid)
      expect(patron).to be_falsey
    end

    it "Returns false when the application isn't authorized to access patron data" do
      unauthorized_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{unauthorized_user.uid}"
      stub_request(:get, unauthorized_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 403, body: '<html><title>Not Authorized</title><body></body></html>', headers: {})
      patron = subject.send(:current_patron?, unauthorized_user.uid)
      expect(patron).to be_falsey
    end

    it 'Returns false when the http response throws 500' do
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 500, body: 'Error', headers: {})
      patron = subject.send(:current_patron?, valid_user.uid)
      expect(patron).to be_falsey
    end
  end

  describe '#borrow_direct_redirect' do
    let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }
    let(:valid_barcode_user) { FactoryGirl.create(:guest_patron) }
    let(:valid_cas_user) { FactoryGirl.create(:valid_princeton_patron) }
    it 'Redirects to Borrow Direct for valid cas user' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: valid_patron_response, headers: {})
      get :borrow_direct_redirect
      expect(response.location).to match(%r{https:\/\/borrow-direct.relaisd2d.com\/})
    end
    it 'Redirect url includes query when present' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: valid_patron_response, headers: {})
      query = 'book title'
      get :borrow_direct_redirect, q: query
      expect(response.location).to match(%r{https:\/\/borrow-direct.relaisd2d.com\/})
      expect(response.location).to include(CGI.escape(query))
    end
    # For interoperability with umlaut
    it 'Redirect url includes query when present' do
      sign_in(valid_cas_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_cas_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: valid_patron_response, headers: {})
      query = 'book title'
      get :borrow_direct_redirect, query: query
      expect(response.location).to match(%r{https:\/\/borrow-direct.relaisd2d.com\/})
      expect(response.location).to include(CGI.escape(query))
    end
    it 'Redirects to CAS login page for non-logged in user' do
      get :borrow_direct_redirect
      expect(response.location).to match(user_cas_omniauth_authorize_path)
    end
    it 'Redirects to Home page for ineligible barcode only user' do
      sign_in(valid_barcode_user)
      valid_patron_record_uri = "#{ENV['bibdata_base']}/patron/#{valid_barcode_user.uid}"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: valid_patron_response, headers: {})
      get :borrow_direct_redirect
      expect(response).to redirect_to(root_url)
    end
  end

  describe '#voyager_account?' do
    let(:valid_voyager_response) { File.open(fixture_path + '/pul_voyager_account_response.xml').read }
    let(:valid_voyager_patron) { JSON.parse(valid_patron_response.read.to_s).with_indifferent_access }
    let(:invalid_voyager_patron) { JSON.parse('{ "patron_id": "foo" }').with_indifferent_access }
    let(:unauthorized_voyager_patron) { JSON.parse('{ "patron_id": "bar" }').with_indifferent_access }

    it 'Returns Voyager account data using a valid patron record' do
      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: valid_voyager_response, headers: {})
      account = subject.send(:voyager_account?, valid_voyager_patron)
      expect(account).to be_truthy
      expect(account.doc.is_a?(Nokogiri::XML::Document)).to be_truthy
    end

    it "Returns false when the patron record doesn't exist" do
      invalid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{invalid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, invalid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 404, body: 'Account Not Found', headers: {})
      account = subject.send(:voyager_account?, invalid_voyager_patron)
      expect(account).to be_falsey
    end

    it "Returns false when the application isn't authorized to access Voyager account data" do
      unauthorized_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{unauthorized_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, unauthorized_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 403, body: 'Application Not Authorized', headers: {})
      account = subject.send(:voyager_account?, unauthorized_voyager_patron)
      expect(account).to be_falsey
    end
  end
end
