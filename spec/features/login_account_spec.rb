require 'rails_helper'

context 'user signs in' do
  let(:user) { FactoryGirl.create(:valid_princeton_patron) }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
  let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
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

context 'user signs in upon visiting a request form' do
  let(:request_path) { '/requests/1424012' }
  let(:show_path) { '/catalog/1424012' }
  let(:user) { FactoryGirl.create(:guest_patron) }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:valid_record_response) { fixture('/8908514.json') }
  it 'redirects the user to the request form' do
    stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
      .to_return(status: 200, body: valid_patron_response, headers: {})
    stub_request(:get, "#{ENV['pulsearch_base']}#{show_path}.json")
      .to_return(status: 200, body: valid_record_response, headers: {})
    visit request_path
    # binding.pry
    click_link('barcode-login')
    # sign_in user
    login_as user
    expect(current_path).to eq request_path
  end
end

# describe 'User logs in' do
#   context 'via the account menu option' do
#     let(:user) { FactoryGirl.create(:valid_princeton_patron) }
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
#     let(:user) { FactoryGirl.create(:valid_princeton_patron) }
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
