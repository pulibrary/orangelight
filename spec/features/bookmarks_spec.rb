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
      click_link "Princeton faculty, staff, and students log in with NetID"
      expect(current_path).to eq bookmarks_path
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

    it "displays bookmarks for old voyager IDs" do
      Bookmark.create(user: user, document_id: "10647164", document_type: "SolrDocument")
      login_as user
      visit "/bookmarks"

      expect(page).to have_content "History."
    end
  end
end
