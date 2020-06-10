# frozen_string_literal: true

require 'rails_helper'

describe 'email form' do
  let(:bibid) { '7994866' }
  let(:user) { FactoryBot.create(:valid_princeton_patron) }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
  let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
  let(:outstanding_ill_requests_response) { File.open(fixture_path + '/outstanding_ill_requests_response.json') }
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
  end

  it 'requires user to sign in' do
    visit "/catalog/#{bibid}/email"
    expect(page).not_to have_button('Send')
  end
  it 'shows send button for authenticated users' do
    stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
      .to_return(status: 200, body: valid_patron_response, headers: {})

    valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
    stub_request(:get, valid_patron_record_uri)
      .to_return(status: 200, body: voyager_account_response, headers: {})
    sign_in user
    visit "/catalog/#{bibid}/email"
    expect(page).to have_button('Send')
  end
end
