# frozen_string_literal: true

require 'rails_helper'

describe 'Availability' do
  describe 'Physical Holdings are displayed on a record page', js: true do
    before do
      stub_holding_locations
      visit '/catalog/3256177'
    end

    it 'within the holdings section', unless: in_ci? do
      expect(page).to have_selector('.availability--physical', count: 1)
    end

    it 'listing individual holdings', unless: in_ci? do
      expect(page).to have_selector('.availability--physical .holding-block', count: 4)
    end
  end

  # This test is quite brittle and will break once this item is removed from
  # CDL. It seems valid to remove it if it hasn't been refactored by then, and
  # at least create an issue to replace it with a jest test during a refactor of
  # this javascript.
  describe 'An item reserved for controlled digital lending', js: true do
    before do
      stub_holding_locations
      visit '/catalog/7699003'
    end

    it 'adds a link to the digital object', unless: in_ci? do
      expect(page).to have_selector('.availability--online a', count: 1)
      expect(page).to have_selector('h3', text: "Available Online")
      expect(page).to have_selector('li', text: "Princeton users: View digital content")
      expect(page).to have_selector('.holding-status', text: "Reserved for digital lending", exact_text: true)
      expect(page).not_to have_selector('a.request')
    end
  end

  describe 'Electronic Holdings are displayed on a record page', js: true do
    it 'within the online section', unless: in_ci? do
      stub_holding_locations
      visit '/catalog/857469'
      expect(page).to have_selector '.availability--online a', minimum: 1
    end

    it 'display umlaut links for marcit record within the online section', unless: in_ci? do
      visit '/catalog/9774256'
      expect(page).to have_selector '.availability--online .umlaut .fulltext', count: 1
      expect(page).to have_selector '.availability--online .umlaut .fulltext .response_item', minimum: 4
    end
  end

  describe 'Physical Holdings in temp locations', js: true do
    it 'displays temp location on search results along with call number', unless: in_ci? do
      stub_holding_locations
      visit '/catalog?q=7917192'
      expect(page).to have_selector '.library-location', text: 'Lewis Library - Term Loan Reserves'
      expect(page).to have_selector '.library-location', text: 'QA303.2 .W45 2014'
    end
    it 'displays temp location and copy on record show', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/7917192'
      expect(page).to have_selector '.library-location', text: 'Lewis Library - Term Loan Reserves'
    end
  end

  describe 'Multiple items all available', js: true do
    it 'display availability as on-site and does not display individual items', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/857469'
      expect(page).to have_selector '.availability-icon.badge.badge-success', text: 'All items available'
    end
  end

  describe 'On-site multiple items all available', js: true do
    it 'displays availability as on-site and does not display individual items', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/7777379'
      expect(page).to have_selector '.availability-icon.badge.badge-success', text: 'On-site access', count: 1
    end
  end

  describe 'On-site multiple items unavailable', js: true do
    it 'displays See front desk and does not display individual items', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/2238036'
      expect(page).to have_selector '.availability-icon.badge.badge-success', text: 'See front desk', count: 1
    end
  end

  describe 'Checked out item', js: true do
    it 'shows due date', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/12052273'
      expect(page).to have_selector '.availability-icon.badge.badge-secondary', text: 'Checked out - 12/30/2020', count: 1
    end
  end

  describe 'Holdings for SCSB records' do
    context 'when a record has no format' do
      it 'still displays the record with a ReCAP location' do
        stub_holding_locations
        visit 'catalog/SCSB-7935196'
        expect(page).to have_selector '.library-location', text: 'ReCAP'
      end
    end
  end

  # There are issues with correctly setting the user agent with chromedriver
  context 'when visited by an indexing bot', driver: :iphone do
    before do
      page.driver.add_headers('User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1 (compatible; AdsBot-Google-Mobile; +http://www.google.com/mobile/adsbot.html)')
    end

    describe 'viewing a catalog record', js: true do
      before do
        stub_holding_locations
        visit '/catalog/3256177'
      end

      xit 'does not render the holding section' do
        expect(page).not_to have_selector('.availability--holding')
      end
    end

    describe 'viewing a record for an electronic holding', js: true do
      before do
        stub_holding_locations
        visit '/catalog/857469'
      end

      xit 'does not render the online section' do
        expect(page).not_to have_selector('.availability--online')
      end
    end

    describe 'viewing a record for a holding in a temp location', js: true do
      before do
        stub_holding_locations
        visit '/catalog?q=7917192'
      end

      xit 'does not render the location' do
        expect(page).not_to have_selector('.availability--holding')
      end
    end
  end

  context 'when using Alma' do
    before do
      allow(Rails.configuration).to receive(:use_alma).and_return(true)
    end

    describe 'Electronic Holdings', js: true do
      it 'within the online section it does not display links', unless: in_ci? do
        stub_holding_locations
        visit '/catalog/99122306151806421'
        expect(page).not_to have_selector '.availability--online a'
      end

      it 'does not display umlaut links for marcit record within the online section', unless: in_ci? do
        visit '/catalog/99122306151806421'
        expect(page).not_to have_selector '.availability--online .umlaut .fulltext'
        expect(page).not_to have_selector '.availability--online .umlaut .fulltext .response_item'
      end
    end
  end
end
