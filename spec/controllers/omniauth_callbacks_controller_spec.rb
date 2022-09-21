# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  let(:valid_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response.json')).with_indifferent_access }
  let(:expired_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_expired.json')).with_indifferent_access }
  let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'logging in' do
    it 'valid cas login redirects to account page' do
      allow(User).to receive(:from_cas) { FactoryBot.create(:valid_princeton_patron) }
      get :cas
      expect(response).to redirect_to(account_path)
    end
    context 'valid alma user' do
      let(:user) { FactoryBot.create(:alma_patron) }
      let(:omniauth_response) { OmniAuth::AuthHash.new(provider: 'alma', uid: user.uid) }
      let(:expected_url) { 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/Student?op=auth&password=whatever' }

      before do
        stub_request(:post, expected_url)
          .to_return(status: 204)
        controller.request.env['omniauth.auth'] = omniauth_response
      end
      it 'redirects to account path' do
        get :alma, params: { username: user.username, password: 'whatever' }

        expect(WebMock).to have_requested(:post, expected_url)
        expect(response).to redirect_to(account_path)
      end
      context "with added spaces in the middle of the username from form" do
        let(:user) { FactoryBot.create(:alma_patron, username: "Juan Hernandez") }
        let(:expected_url) { 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/Juan%20Hernandez?op=auth&password=whatever' }

        it 'redirects to account path' do
          get :alma, params: { username: user.username, password: 'whatever' }

          expect(WebMock).to have_requested(:post, expected_url)
          expect(response).to redirect_to(account_path)
        end
      end
      context "with an added space at the begginning of the username" do
        let(:user) { FactoryBot.create(:alma_patron, username: "BC001111111") }
        let(:expected_url) { 'https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/BC001111111?op=auth&password=whatever' }

        it 'redirects to account path' do
          get :alma, params: { username: user.username.to_s, password: 'whatever' }

          expect(WebMock).to have_requested(:post, expected_url)
          expect(response).to redirect_to(account_path)
        end
      end
    end
  end
end
