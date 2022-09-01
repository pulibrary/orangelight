# frozen_string_literal: true

require 'rails_helper'

describe 'email form' do
  let(:bibid) { '9979948663506421' }
  let(:user) { FactoryBot.create(:valid_princeton_patron) }

  it 'requires user to sign in' do
    visit "/catalog/#{bibid}/email"
    expect(page).not_to have_button('Send')
  end

  it 'shows send button for authenticated users' do
    sign_in user
    visit "/catalog/#{bibid}/email"
    expect(page).to have_button('Send')
  end
end
