# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'bookmarks' do
  describe 'action buttons' do
    it 'has a clear bookmarks button' do
      visit '/bookmarks'
      expect(page).to have_link("Clear bookmarks")
    end
  end

  context 'when not logged in' do
    it 'has login links' do
      visit '/bookmarks'
      within('#content') do
        expect(page).to have_link("log in")
      end
    end

    it 'logging in brings user back to bookmarks page' do
      visit '/bookmarks'
      click_link "log in"
      click_link I18n.t('blacklight.login.netid_login_msg')
      expect(current_path).to eq bookmarks_path
    end
  end

  context 'when orangelight is in readonly mode' do
    it 'has a maintenance message' do
      allow(Orangelight).to receive(:read_only_mode).and_return(true)
      visit '/bookmarks'
      within('#content') do
        expect(page).not_to have_link("log in")
        expect(page).to have_content("unavailable during maintenance")
      end
    end
  end

  context 'when logged in' do
    let(:user) { FactoryBot.create(:user) }

    it 'does not have login links' do
      login_as user
      visit '/bookmarks'
      within('#content') do
        expect(page).not_to have_link("log in")
      end
    end

    it "only displays bookmarked titles" do
      stub_holding_locations
      Bookmark.create(user:, document_id: "99122304923506421", document_type: "SolrDocument")
      login_as user
      visit "/bookmarks"

      expect(page).to have_content "1 entry found"
    end

    it "updates the count of bookmarks when a user removes a bookmark", js: true do
      stub_holding_locations
      Bookmark.create(user:, document_id: "99122304923506421", document_type: "SolrDocument")
      login_as user
      visit "/bookmarks"
      expect(page).to have_content 'Bookmarks (1)'

      click_button 'In Bookmarks'

      expect(page).to have_content 'Bookmarks (0)'
    end
  end
end
