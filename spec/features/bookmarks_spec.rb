# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'bookmarks' do
  describe 'action buttons' do
    it 'has a clear bookmarks button' do
      visit '/bookmarks'
      expect(page).to have_link("Clear bookmarks")
    end

    context 'when using Voyager' do
      it 'does not have a login button' do
        visit '/bookmarks'
        within('#content') do
          expect(page).not_to have_link("Login")
        end
      end
    end

    context 'when using Alma, not logged in' do
      before do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
      end

      it 'has a login button' do
        visit '/bookmarks'
        within('#content') do
          expect(page).to have_link("Login", class: "btn-primary")
        end
      end
    end

    context 'when using Alma, logged in' do
      let(:user) { FactoryBot.create(:user) }
      before do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
        login_as user
      end

      it 'does not have a login button' do
        visit '/bookmarks'
        within('#content') do
          expect(page).not_to have_link("Login", class: "btn-primary")
        end
      end
    end
  end
end
