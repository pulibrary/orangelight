# frozen_string_literal: true

require 'rails_helper'

describe 'stackmap', type: :system, js: true do
  before do
    stub_holding_locations
  end
  context 'with Firestone Locator off' do
    before do
      allow(Flipflop).to receive(:firestone_locator?).and_return(false)
    end

    it 'has a link to the stackmap on the record page' do
      visit '/catalog/99125428126306421'
      click_button('Where to find it', wait: 5)
      expect(page).to have_button('zoom in')
    end

    it 'has a link to the stackmap on the search results page' do
      visit '/catalog?search_field=all_fields&q='
      expect(page).to have_button('Where to find it', wait: 5)
    end
  end

  context 'with Firestone Locator on' do
    before do
      allow(Flipflop).to receive(:firestone_locator?).and_return(true)
    end

    it 'has a link to the stackmap on the search results page' do
      visit '/catalog?search_field=all_fields&q='
      expect(page).to have_no_button('Map it', wait: 5)
      expect(page).to have_link('Where to find it')
    end

    context 'with Firestone item' do
      it 'opens a modal with the Firestone Locator' do
        visit '/catalog/99125428126306421'
        expect(page).to have_link('Where to find it')
        expect(page).to have_no_button('Map it', wait: 5)
        click_link('Where to find it')
        iframe = find('iframe')
        expect(iframe['src']).to eq('https://locator-prod.princeton.edu/index.php?loc=firestone$clas&id=99125428126306421&embed=true')
      end
    end

    context 'with non-Firestone item' do
      it 'opens a modal with the Stackmap locator' do
        visit '/catalog/99116547863506421'
        expect(page).to have_link('Where to find it')
        expect(page).to have_no_button('Map it', wait: 5)
        click_link('Where to find it')
        iframe = find('iframe')
        expect(iframe['src']).to eq('https://princeton.stackmap.com/view/?callno=J3306%2F5047.4+pt.31&library=East+Asian+Library&location=eastasian%24hy')
      end
    end
  end
end
