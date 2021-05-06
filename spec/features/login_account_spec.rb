# frozen_string_literal: true

require 'rails_helper'

describe 'Account login' do
  let(:alma_account_url) { "https://princeton.alma.exlibrisgroup.com/discovery/account?vid=01PRI_INST:Services&lang=EN&section=overview" }

  describe 'sign in' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
    before do
      ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
      current_illiad_user_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/jstudent"
      stub_request(:get, current_illiad_user_uri).to_return(status: 404, body: '{"Message":"User jstudent was not found."}')
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

  describe 'login link', js: true do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    it "goes to the sign in page" do
      visit "/"
      click_button("Your Account")
      expect(page).to have_link("Login", href: "/users/sign_in")
    end

    context 'when using Alma' do
      before do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
      end

      it "opens the library card app in a new window" do
        visit "/"
        click_button("Your Account")
        expect(page).to have_link("Your Account", href: alma_account_url)
        expect(find_link("Your Account")[:target]).to eq("_blank")
      end
    end
  end

  describe 'Your Account link for logged in user', js: true do
    let(:user) { FactoryBot.create(:user) }
    before do
      login_as user
    end

    it "goes to the account page" do
      visit "/"
      click_button(user.username)
      link = find_link("Your Account")
      expect(URI(link[:href]).path).to eq "/account"
    end

    context 'when using Alma' do
      before do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
      end

      it "opens the library card app in a new window" do
        visit "/"
        click_button(user.username)
        link = find_link("Your Account")
        expect(link[:href]).to eq alma_account_url
      end
    end
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
