require 'rails_helper'

context 'user signs in' do
  let(:user) { FactoryGirl.create(:valid_princeton_patron) }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
  let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
  let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
  it 'brings user to account page' do
    stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
      .with(headers: { 'User-Agent' => 'Faraday v0.9.2' })
      .to_return(status: 200, body: valid_patron_response, headers: {})

    valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
    stub_request(:get, valid_patron_record_uri)
      .with(headers: { 'User-Agent' => 'Faraday v0.9.2' })
      .to_return(status: 200, body: voyager_account_response, headers: {})
    sign_in user
    expect(current_path).to eq account_path
  end
end
