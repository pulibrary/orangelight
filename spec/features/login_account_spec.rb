# frozen_string_literal: true

require 'rails_helper'

context 'user signs in' do
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
  it 'brings user to account page' do
    stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
      .to_return(status: 200, body: valid_patron_response, headers: {})

    valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
    stub_request(:get, valid_patron_record_uri)
      .to_return(status: 200, body: voyager_account_response, headers: {})
    sign_in user
    expect(current_path).to eq account_path
  end
end

# describe 'User logs in' do
#   context 'via the account menu option' do
#     let(:user) { FactoryBot.create(:valid_princeton_patron) }
#     let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
#     let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
#     let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
#     it 'brings user to the account page' do
#       stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
#         .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
#         .to_return(status: 200, body: valid_patron_response, headers: {})

#       valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
#       stub_request(:get, valid_patron_record_uri)
#         .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
#         .to_return(status: 200, body: voyager_account_response, headers: {})
#       sign_in @user
#       expect(current_path).to eq account_path
#     end
#   end

#   context 'from the request page' do
#     let(:requestable_record) { 890_851_4 }
#     let(:user) { FactoryBot.create(:valid_princeton_patron) }
#     let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
#     it 'brings user back to the request page when the request is initiated from there' do
#       stub_request(:get, 'https://pulsearch.princeton.edu/catalog/8908514.json')
#         .with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Faraday v0.11.0' })
#         .to_return(status: 200, body: fixture('/8908514.json'), headers: {})
#       stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
#         .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
#         .to_return(status: 200, body: valid_patron_response, headers: {})
#       visit "/requests/#{requestable_record}"
#       expect(page).to have_content I18n.t('requests.account.guest').to_s
#       click_link(I18n.t('requests.account.guest').to_s)
#       expect(current_path).to eq "/requests/#{requestable_record}"
#     end
#   end
# end
