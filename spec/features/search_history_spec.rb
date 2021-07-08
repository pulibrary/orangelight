# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'search history' do
  context 'when not logged in' do
    context 'and no searches have been performed' do
      it 'has login links' do
        visit '/search_history'
        within('#content') do
          expect(page).to have_link("log in")
        end
      end

      it 'logging in brings user back to search history page' do
        visit '/search_history'
        click_link "log in"
        click_link "Princeton faculty, staff, and students log in with NetID"
        expect(current_path).to eq blacklight.search_history_path
      end
    end

    context 'and searches have been performed' do
      it 'has login links' do
        stub_holding_locations
        visit '/'
        find_button('search').click
        visit '/search_history'
        within('#content') do
          expect(page).to have_link("log in")
        end
      end
    end
  end

  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }

    it 'does not have login links' do
      login_as user
      visit '/search_history'
      within('#content') do
        expect(page).not_to have_link("log in")
      end
    end
  end
end
