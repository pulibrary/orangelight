# frozen_string_literal: true

require 'rails_helper'

describe 'browsing a catalog item', js: true do
  before do
    stub_alma_holding_locations
  end

  context 'accessible icons' do
    before do
      visit 'catalog/99125535710106421'
    end
    it 'renders an accessible icon for citing the item' do
      expect(page).to have_selector('span.icon-cite[aria-hidden="true"]')
    end
    it 'renders an accessible icon for sending items to a printer' do
      expect(page).to have_selector('span.icon-share[aria-hidden="true"]')
      expect(page).to have_selector('span.icon-print[aria-hidden="true"]', visible: :hidden)
    end
  end

  context 'when an item does not have a format value' do
    before do
      visit 'catalog/SCSB-7935196'
    end

    it 'has a default icon even if there is no fomat value' do
      content = page.evaluate_script <<-SCRIPT
        (function() {
          var element = document.getElementsByClassName('default')[0];
          return window.getComputedStyle(element, ':before').getPropertyValue('content')
        })()
      SCRIPT

      expect(page).to have_content('Analectas')
      # The square symbol is the unicode symbol for \ue60b which correlates
      # to the unicode identifer for the book icon
      expect(content).to eq('""')
    end
  end
end
