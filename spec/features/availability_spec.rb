# frozen_string_literal: true
require 'rails_helper'

describe 'Availability' do
  describe 'Physical Holdings are displayed on a record page', js: true do
    before do
      stub_holding_locations
      visit '/catalog/9932561773506421'
    end

    it 'within the holdings section', unless: in_ci? do
      expect(page).to have_selector('.availability--physical', count: 1)
    end

    it 'listing individual holdings', unless: in_ci? do
      expect(page).to have_selector('.availability--physical .holding-block', count: 4)
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
        visit '/catalog/9932561773506421'
      end

      xit 'does not render the holding section' do
        expect(page).not_to have_selector('.availability--holding')
      end
    end

    describe 'viewing a record for an electronic holding', js: true do
      before do
        stub_holding_locations
        visit '/catalog/998574693506421'
      end

      xit 'does not render the online section' do
        expect(page).not_to have_selector('.availability--online')
      end
    end

    describe 'viewing a record for a holding in a temp location', js: true do
      before do
        stub_holding_locations
        visit '/catalog?q=9979171923506421'
      end

      xit 'does not render the location' do
        expect(page).not_to have_selector('.availability--holding')
      end
    end
  end

  # This test is quite brittle and will break once this item is removed from
  # CDL. It seems valid to remove it if it hasn't been refactored by then, and
  # at least create an issue to replace it with a jest test during a refactor of
  # this javascript.

  # this item is no longer on CDL
  xdescribe 'An item reserved for controlled digital lending', js: true do
    before do
      stub_holding_locations
      visit '/catalog/9976990033506421'
    end

    it 'adds a link to the digital object', unless: in_ci? do
      expect(page).to have_selector('.availability--online a', count: 1)
      expect(page).to have_selector('h3', text: "Available Online")
      expect(page).to have_selector('li', text: "Princeton users: View digital content")
      expect(page).to have_selector('.holding-status', text: "Reserved for digital lending", exact_text: true)
      expect(page).not_to have_selector('a.request')
    end
  end

  # This item is no longer in a temp location
  xdescribe 'Physical Holdings in temp locations', js: true do
    it 'displays temp location on search results along with call number', unless: in_ci? do
      stub_holding_locations
      visit '/catalog?q=9979171923506421'
      expect(page).to have_selector '.library-location', text: 'Lewis Library - Term Loan Reserves'
      expect(page).to have_selector '.library-location', text: 'QA303.2 .W45 2014'
    end
    it 'displays temp location and copy on record show', unless: in_ci? do
      stub_holding_locations
      visit 'catalog/9979171923506421'
      expect(page).to have_selector '.library-location', text: 'Lewis Library - Term Loan Reserves'
    end
  end

  describe 'Electronic Holdings' do
    it "displays an online badge in search results" do
      stub_holding_locations
      visit "/catalog?q=99122306151806421"

      expect(page).to have_selector ".availability-icon", text: "Online"
    end
    it 'within the online section, it displays electronic portfolio links' do
      visit '/catalog/99122306151806421'
      expect(page).to have_text '1869 - 1923: Biodiversity Heritage Library Free'
      expect(page).to have_text 'Available from 1869 volume: 1 issue: 1.'

      # Electronic portfolio link with an embargo
      expect(page).to have_text '1990 - 2020: ProQuest Central'

      # Renders portfolio link that does not include a date range
      expect(page).to have_text 'PressReader'
      expect(page).not_to have_text ': PressReader'
    end

    it 'does not display umlaut links for marcit record within the online section', js: true do
      visit '/catalog/99122306151806421'
      expect(page).not_to have_selector '.availability--online .umlaut .fulltext'
      expect(page).not_to have_selector '.availability--online .umlaut .fulltext .response_item'
    end

    context 'with a sibling record that does not have electronic portfolio values' do
      it 'within the online section, it displays the links of its sibling record' do
        stub_holding_locations
        visit '/catalog/994264203506421'
        expect(page).to have_text '1869 - 1923: Biodiversity Heritage Library Free'
        expect(page).to have_text 'Available from 1869 volume: 1 issue: 1.'
      end
    end
  end
end
