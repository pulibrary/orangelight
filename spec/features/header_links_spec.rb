# frozen_string_literal: true

require 'rails_helper'

describe 'Tools links' do
  before { stub_holding_locations }

  context 'With MARC-based records' do
    before do
      visit '/catalog/10585552'
    end

    it 'displays links in the navbar, account dropdown, and record view' do
      expect(page).to have_selector('.navbar-item * a', text: 'Course Reserves')
      expect(page).to have_selector('.navbar-item * a', text: 'Bookmark')
      expect(page).to have_button('Send to')

      within '.menu--level-1' do
        expect(page).to have_link('Login')
        expect(page).to have_link('Search History')
      end

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
      visit  '/catalog/dsp01ft848s955'
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
