# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountController do
  let(:current_illiad_user_uri) { "#{Requests::Config[:illiad_api_base]}/ILLiadWebPlatform/Users/jstudent" }
  let(:valid_patron_response) { File.open('spec/fixtures/bibdata_patron_response.json') }
  let(:verify_user_response) { File.open('spec/fixtures/ill_verify_user_response.json') }
  let(:outstanding_ill_requests_response) { File.open('spec/fixtures/outstanding_ill_requests_response.json') }
  let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
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
    valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}"
    stub_request(:get, valid_patron_record_uri)
      .to_return(status: 200, body: valid_patron_response, headers: {})
  end

  describe "#redirect_to_alma" do
    context "as an unauthenticated user" do
      it "sends the user to the login page" do
        get "/users/sign_in?origin=%2Fredirect-to-alma"
        expect(response).to be_successful
      end
    end
    context "as an authenticated user" do
      before do
        login_as(valid_user)
      end

      it "sends the user to the redirect to alma page" do
        get "/users/sign_in?origin=%2Fredirect-to-alma"
        expect(response).to redirect_to("/redirect-to-alma")

        follow_redirect!

        expect(response).to render_template(:redirect_to_alma)
      end
    end
  end
  describe "#index" do
    it "redirects to digitization_requests" do
      login_as(valid_user)
      get "/account"

      expect(response).to redirect_to "/account/digitization_requests"
    end
  end
  describe "#digitization_requests" do
    context "when not logged in" do
      it "redirects to CAS" do
        get "/account/digitization_requests"

        expect(response).to redirect_to "/users/sign_in?referer=%2Faccount%2Fdigitization_requests"
      end
    end
    context "when logged in" do
      it "renders digitization requests" do
        login_as(valid_user)
        get "/account/digitization_requests"

        expect(response.body).to have_content "Outstanding Inter Library Loan and Digitization Requests"
        expect(response.body).to have_content "Pʹesy"
      end
    end
  end

  context 'with old borrow direct provider' do
    context 'when logged in' do
      before do
        login_as(valid_user)
        allow(Flipflop).to receive(:reshare_for_borrow_direct?).and_return(false)
      end
      it 'Links to borrow direct route to #borrow_direct_redirect' do
        get '/borrow-direct'
        expect(request.parameters).to eq({ "controller" => "account", "action" => "borrow_direct_redirect" })
        expect(response.location).to match(RELAIS_BASE)
      end
    end
  end
  context 'with new borrow direct provider' do
    before do
      allow(Flipflop).to receive(:reshare_for_borrow_direct?).and_return(true)
    end

    it 'Links directly to the new borrow direct provider' do
      get '/borrow-direct'
      expect(response).to redirect_to('https://borrowdirect.reshare.indexdata.com/')
    end
  end
end
