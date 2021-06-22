# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountController do
  let(:current_illiad_user_uri) { "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/jstudent" }
  let(:valid_patron_response) { File.open(fixture_path + '/bibdata_patron_response.json') }
  let(:verify_user_response) { File.open(fixture_path + '/ill_verify_user_response.json') }
  let(:outstanding_ill_requests_response) { File.open(fixture_path + '/outstanding_ill_requests_response.json') }
  let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
  before do
    ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
    current_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Transaction/UserRequests/jstudent?$filter=" \
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
  describe "#index" do
    context "when alma is set up and you're logged in" do
      it "redirects to digitization_requests" do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
        sign_in(valid_user)
        get "/account"

        expect(response).to redirect_to "/account/digitization_requests"
      end
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
        sign_in(valid_user)
        get "/account/digitization_requests"

        expect(response.body).to have_content "Outstanding Digitization Requests"
        expect(response.body).to have_content "Pʹesy"
      end
    end
  end
end
