# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  let(:valid_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response.json')).with_indifferent_access }
  let(:expired_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_expired.json')).with_indifferent_access }
  let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }
  let(:valid_barcode_user) { FactoryBot.create(:guest_patron) }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'callback response to User object' do
    let(:last_name) { 'LastName' }
    let(:uid) { '12345678901234' }
    let(:omniauth_response) do
      OmniAuth::AuthHash.new(provider: 'barcode', uid: uid, info:
        { last_name: last_name })
    end

    it 'last_name is mapped to username property' do
      expect(User.from_barcode(omniauth_response).username).to eq last_name
    end
    it 'provider property gets set' do
      expect(User.from_barcode(omniauth_response).provider).to eq 'barcode'
    end
  end

  describe 'bad omniauth session' do
    let(:omniauth_response_nil_uid) do
      OmniAuth::AuthHash.new(provider: 'barcode', uid: nil, info: { last_name: "" })
    end
    before do
      controller.request.env['omniauth.auth'] = omniauth_response_nil_uid
    end
    it 'handles nil UID' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(account_path)
    end
  end

  describe 'logging in' do
    it 'valid cas login redirects to account page' do
      allow(User).to receive(:from_cas) { FactoryBot.create(:valid_princeton_patron) }
      get :cas
      expect(response).to redirect_to(account_path)
    end
    it 'valid guest barcode redirects to account page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(account_path)
    end
    context 'with a valid guest barcode containing whitespace' do
      let(:last_name) { 'LastName' }
      let(:uid) { '22101 002369676' }
      let(:omniauth_response) { OmniAuth::AuthHash.new provider: 'barcode', uid: uid, info: { last_name: last_name } }

      before do
        controller.request.env['omniauth.auth'] = omniauth_response
        stub_request(:get, 'https://bibdata-staging.princeton.edu/patron/22101002369676').to_return(status: 200, body: JSON.generate(guest_response))
      end

      it 'strips the whitespace' do
        get :barcode
        expect(assigns(:user)).to be_a User
        user = assigns(:user)
        expect(user.uid).to eq '22101002369676'
      end
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

    it 'invalid patron redirects to login page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { {} }
      get :barcode
      expect(response).to redirect_to(user_barcode_omniauth_authorize_path)
    end
    it 'valid patron, invalid last name, redirects to login page' do
      allow(User).to receive(:from_barcode) { FactoryBot.create(:guest_patron, username: 'nope') }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(user_barcode_omniauth_authorize_path)
    end
    it 'valid patron, invalid barcode, redirects to login page' do
      allow(User).to receive(:from_barcode) { FactoryBot.build(:guest_patron, uid: 'notabarcode') }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(user_barcode_omniauth_authorize_path)
    end
    it 'valid netid barcode redirects to login page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { valid_netid_response }
      get :barcode
      expect(response).to redirect_to(user_barcode_omniauth_authorize_path)
    end
    it 'expired netid barcode redirects to account page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { expired_netid_response }
      get :barcode
      expect(response).to redirect_to(account_path)
    end
    context 'when a 429 response is received from the Alma API endpoint' do
      before do
        allow(User).to receive(:from_barcode) { valid_barcode_user }
        allow(Bibdata).to receive(:get_patron).and_raise(Bibdata::PerSecondThresholdError)
      end

      it 'redirects to the account page with an error message for the user' do
        client = get(:barcode)

        expect(response).to redirect_to(user_barcode_omniauth_authorize_path)

        expect(client.request.flash[:error]).not_to be_empty
        expect(client.request.flash[:error]).to eq("Could not authenticate because the current request load is high. Please try again.")
      end
    end
  end
end
