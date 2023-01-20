# frozen_string_literal: true

require 'rails_helper'

describe 'Showing flash messages', type: :system, js: true do
  describe "emailing a bookmark" do
    let(:user) { FactoryBot.create(:user) }
    let(:document) { SolrDocument.new(id: '9947055653506421') }
    let(:bookmark) { Bookmark.create!(user:, document:) }
    before do
      stub_holding_locations
      login_as(user)
      bookmark
    end
    it 'displays one flash message on the main page' do
      pending("Not duplicating flash messages on the main page")
      expect(user.bookmarks).not_to be_empty
      visit('/bookmarks')
      expect(page).to have_content("Die Geschichte Joseph's und seiner Brüder")
      click_on("Email")
      expect(page).to have_content("Email the catalog record and (optional) message.")
      fill_in('Email:', with: 'foo@example.com')
      click_on('Send')
      expect(page).to have_content("Email Sent")
      page.find('.flash_messages')
      # expect(page).to have_css('.flash_messages')
    end
  end
end
