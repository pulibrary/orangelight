# frozen_string_literal: true

require 'rails_helper'

describe 'email form' do
  let(:bibid) { '9979948663506421' }
  let(:user) { FactoryBot.create(:valid_princeton_patron) }
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }

  before do
    current_illiad_user_uri = "#{Requests::Config[:illiad_api_base]}/ILLiadWebPlatform/Users/jstudent"
    stub_request(:get, current_illiad_user_uri).to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
  end

  it 'requires user to sign in' do
    visit "/catalog/#{bibid}/email"
    expect(page).not_to have_button('Send')
  end

  it 'shows send button for authenticated users' do
    stub_request(:get, "#{Requests.config['bibdata_base']}/patron/#{user.uid}")
      .to_return(status: 200, body: valid_patron_response, headers: {})
    sign_in user
    visit "/catalog/#{bibid}/email"
    expect(page).to have_button('Send')
  end
end
