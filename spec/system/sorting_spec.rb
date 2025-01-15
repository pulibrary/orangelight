# frozen_string_literal: true

require 'rails_helper'

describe 'sorting', type: :system, js: false do
  let(:user) { FactoryBot.create(:user) }

  before do
    stub_holding_locations
  end

  context 'the catalog page' do
    it 'includes relevance' do
      visit '/catalog?search_field=all_fields&q=engineering'
      sort_dropdown = page.find("#sort-dropdown")
      expect(sort_dropdown.text).to eq("Sort by relevance\nrelevance year (newest first) year (oldest first) author title date cataloged")
      sort_dropdown.click
      within('#sort-dropdown') do
        expect(page).to have_link('relevance')
        expect(page).not_to have_link('library')
      end
    end
  end

  context 'the bookmarks page' do
    before do
      Bookmark.create(user:, document_id: "99106471643506421", document_type: "SolrDocument")
      login_as user
      visit "/bookmarks"
    end

    it 'includes library' do
      sort_dropdown = page.find("#sort-dropdown")
      expect(sort_dropdown.text).to eq("Sort by relevance\nrelevance library year (newest first) year (oldest first) author title date cataloged")
      sort_dropdown.click
      within('#sort-dropdown') do
        expect(page).to have_link('relevance')
        expect(page).to have_link('library')
      end
    end
  end
end
