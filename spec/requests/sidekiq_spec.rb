# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'Sidekiq UI' do
  it 'denies access to the sidekiq UI to non-admins' do
    user = FactoryBot.create(:user)
    login_as user
    expect do
      visit '/sidekiq'
    end.to raise_error ActionController::RoutingError
  end
  it 'allows access to the sidekiq UI to admins' do
    user = FactoryBot.create(:user)
    allow(user).to receive(:admin?).and_return true
    login_as user
    visit '/sidekiq'
    expect(page).to have_text 'Sidekiq'
  end
end
