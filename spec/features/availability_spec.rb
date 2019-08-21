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

  describe 'On-site multiple items all available', js: true do
    it 'display availability as on-site and does not display individual items', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/2238036'
      expect(page).to have_selector '.availability-icon.label.label-success', text: 'On-site access', count: 1
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
end
