require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  let(:valid_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response.json')).with_indifferent_access }
  let(:expired_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_expired.json')).with_indifferent_access }
  let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }
  let(:valid_barcode_user) { FactoryGirl.create(:guest_patron) }
  before(:each) { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'callback response to User object' do
    let(:last_name) { 'LastName' }
    let(:omniauth_response) do
      OmniAuth::AuthHash.new(provider: 'barcode', uid: '12345678901234', info:
        { last_name: last_name }
                            )
    end
    it 'last_name is mapped to username property' do
      expect(User.from_barcode(omniauth_response).username).to eq last_name
    end
    it 'provider property gets set' do
      expect(User.from_barcode(omniauth_response).provider).to eq 'barcode'
    end
  end

  describe 'logging in' do
    it 'valid cas login redirects to account page' do
      allow(User).to receive(:from_cas) { FactoryGirl.create(:valid_princeton_patron) }
      get :cas
      expect(response).to redirect_to(account_path)
    end
    it 'valid guest barcode redirects to account page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(account_path)
    end
    it 'invalid patron redirects to login page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { {} }
      get :barcode
      expect(response).to redirect_to(new_user_session_path)
    end
    it 'valid patron, invalid last name, redirects to login page' do
      allow(User).to receive(:from_barcode) { FactoryGirl.create(:guest_patron, username: 'nope') }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(new_user_session_path)
    end
    it 'valid patron, invalid barcode, redirects to login page' do
      allow(User).to receive(:from_barcode) { FactoryGirl.build(:guest_patron, uid: 'notabarcode') }
      allow(Bibdata).to receive(:get_patron) { guest_response }
      get :barcode
      expect(response).to redirect_to(new_user_session_path)
    end
    it 'valid netid barcode redirects to login page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { valid_netid_response }
      get :barcode
      expect(response).to redirect_to(new_user_session_path)
    end
    it 'expired netid barcode redirects to account page' do
      allow(User).to receive(:from_barcode) { valid_barcode_user }
      allow(Bibdata).to receive(:get_patron) { expired_netid_response }
      get :barcode
      expect(response).to redirect_to(account_path)
    end
  end
end
