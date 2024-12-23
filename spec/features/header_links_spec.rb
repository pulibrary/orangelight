# frozen_string_literal: true

require 'rails_helper'

describe 'Tools links', js: true do
  before { stub_holding_locations }

  context 'With MARC-based records' do
    before do
      visit '/catalog/99115031773506421'
    end

    it 'displays links in the navbar, account dropdown, and record view' do
      expect(page).to have_selector('.nav-item a', text: 'Bookmark')
      expect(page).to have_button('Send to')
      expect(page).not_to have_selector('.nav-item a', text: 'Course Reserves')

      click_button "Your Account"
      within '.lux-show' do
        expect(page).to have_link('Search History')
        expect(page).to have_link('Bookmarks')
      end

      click_button "Send to"
      within '#main-container' do
        expect(page).to have_link('SMS')
        expect(page).to have_link('Email')
        expect(page).to have_link('Staff view')
        expect(page).to have_link('Cite')
      end

      within '.search-widgets li.dropdown' do
        expect(page).to have_link('RefWorks')
        expect(page).to have_link('EndNote')
      end
    end
  end

  context 'With non-MARC-based records' do
    before do
      visit  '/catalog/dsp017s75dc44p'
    end

    it 'does not have cite, RefWorks, or EndNote links' do
      within '#main-container' do
        expect(page).not_to have_link('Cite')
      end

      within '.search-widgets li.dropdown' do
        expect(page).not_to have_link('RefWorks')
        expect(page).not_to have_link('EndNote')
      end
    end
  end
end
