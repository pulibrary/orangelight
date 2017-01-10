require 'rails_helper'

describe 'Availability' do
  describe 'Physical Holdings are displayed on a record page', js: true do
    before(:each) do
      visit '/catalog/3256177'
    end

    it 'within the holdings section', unless: in_travis? do
      expect(page).to have_selector('.location--holding', count: 1)
    end

    it 'listing invidividual holdings', unless: in_travis? do
      expect(page).to have_selector('.location--holding .holding-block', count: 4)
    end

    xit 'with individual copies display', unless: in_travis? do
      # Add via Bib data
    end
  end

  describe 'Electronic Holdings are displayed on a record page', js: true do
    it 'within the online section', unless: in_travis? do
      visit '/catalog/857469'
      expect(page).to have_selector '.location--online .panel-body a', count: 1
    end

    it 'display umlaut links for marcit record within the online section', unless: in_travis? do
      visit '/catalog/9774256'
      expect(page).to have_selector '.location--online .umlaut .fulltext', count: 1
      expect(page).to have_selector '.location--online .umlaut .fulltext .response_item', minimum: 4
    end
  end

  describe 'Physical Holdings in temp locations', js: true do
    it 'displays temp location on search results along with call number' do
      visit '/catalog?q=7917192'
      expect(page).to have_selector '.library-location', text: 'Lewis Library - Course Reserve'
      expect(page).to have_selector '.library-location', text: 'QA303.2 .W45 2014'
    end
    it 'displays temp location and copy on record show' do
      visit 'catalog/7917192'
      expect(page).to have_selector 'h3.library-location', text: 'Lewis Library - Course Reserve'
    end
  end

  describe 'multiple locations within a single holding', js: true do
    it 'individual locations display and do not trigger unavailable label' do
      visit 'catalog/2585108'
      expect(page).to have_selector '.availability-icon.label.label-success', text: 'All items available'
      expect(page).to have_selector 'li', text: 'vol.2: East Asian Library - Reserve - Available (Not charged)'
    end
  end

  describe 'On-site multiple items all available', js: true do
    it 'display availability as on-site and does not display individual items' do
      visit 'catalog/2238036'
      expect(page).to have_selector '.availability-icon.label.label-success', text: 'On-site access', count: 1
      expect(page).not_to have_selector 'ul.item-status'
    end
  end
end
