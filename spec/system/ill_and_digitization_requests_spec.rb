# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'with an active ill/digitization request', type: :system, js: true do
  let(:valid_patron_response) { File.open('spec/fixtures/bibdata_patron_response.json') }
  let(:outstanding_ill_requests_response) { File.open('spec/fixtures/outstanding_ill_requests_response.json') }
  let(:verify_user_response) { File.open('spec/fixtures/ill_verify_user_response.json') }
  let(:current_illiad_user_uri) { "#{Requests.config[:illiad_api_base]}/ILLiadWebPlatform/Users/jstudent" }
  let(:valid_user) { FactoryBot.create(:valid_princeton_patron) }
  let(:cancel_ill_requests_response) { File.open('spec/fixtures/cancel_ill_requests_response.json') }
  let(:cancel_ill_requests_uri) { "#{Requests.config[:illiad_api_base]}/ILLiadWebPlatform/transaction/1094508/route" }
  before do
    login_as valid_user
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
    valid_patron_record_uri = "#{Requests.config['bibdata_base']}/patron/#{valid_user.uid}?ldap=false"
    stub_request(:get, valid_patron_record_uri)
      .to_return(status: 200, body: valid_patron_response, headers: {})
    stub_request(:put, cancel_ill_requests_uri)
      .with(body: "{\"Status\":\"Cancelled by Customer\"}")
      .to_return(status: 200, body: cancel_ill_requests_response, headers: {
                   'Content-Type' => 'application/json',
                   'Apikey' => 'TESTME'
                 })
  end
  it 'shows an alert on success' do
    pending("WIP")
    visit '/account/digitization_requests/'
    check('cancel-1094508')
    click_button 'Cancel requests'
    expect(page).to have_content I18n.t('blacklight.account.cancel_success')
  end
end
