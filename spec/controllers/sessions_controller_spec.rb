# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController do
  let(:valid_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response.json')).with_indifferent_access }
  let(:expired_netid_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_expired.json')).with_indifferent_access }
  let(:guest_response) { JSON.parse(File.read(fixture_path + '/bibdata_patron_response_guest.json')).with_indifferent_access }
  let(:valid_barcode_user) { FactoryBot.create(:guest_patron, username: 'Student') }

  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'logging out' do
    it 'cas user redirects to cas logout page' do
      sign_in FactoryBot.create(:valid_princeton_patron)
      delete :destroy
      expect(response).to redirect_to(Rails.configuration.x.after_sign_out_url)
    end
    it 'barcode user redirects to catalog home page' do
      sign_in FactoryBot.create(:guest_patron)
      delete :destroy
      expect(response).to redirect_to(root_url)
    end
  end
end
