require 'rails_helper'

describe 'Availability' do
  describe 'Physical Holdings are displayed on a record page', js: true do
    before(:each) do
      visit '/catalog/3256177'
    end

    it 'within the holdings section', unless: in_travis? do
      sleep 5.seconds
      expect(page.all('.location--holding').length).to eq 1
    end

    it 'listing invidividual holdings', unless: in_travis? do
      sleep 5.seconds
      expect(page.all('.location--holding .holding-block').length).to eq 4
    end

    xit 'with individual copies display', unless: in_travis? do
      # Add via Bib data
    end
  end

  describe 'Electronic Holdings are displayed on a record page', js: true do
    it 'within the online section', unless: in_travis? do
      visit '/catalog/857469'
      sleep 5.seconds
      expect(page.all('.location--online').length).to eq 1
      expect(page.all('.location--online .panel-body a').length).to eq 1
    end

    it 'display umlaut links for marcit record within the online section', unless: in_travis? do
      visit '/catalog/8606339'
      sleep 5.seconds
      expect(page.all('.location--online .umlaut .fulltext').length).to eq 1
      expect(page.all('.location--online .umlaut .fulltext .response_item').length).to be >= 4
    end
  end

  describe 'Physical Holdings in temp locations', js: true do
    it 'displays temp location on search results' do
      visit '/catalog?q=7917192'
      sleep 5.seconds
      expect(page.all('.library-location', text: 'Lewis Library - Term Loan Reserves').length).to be > 0
    end
    it 'displays temp location and copy on record show' do
      visit 'catalog/7917192'
      sleep 5.seconds
      expect(page.all('h3.library-location', text: 'Lewis Library - Term Loan Reserves').length).to be > 0
    end
  end
end
