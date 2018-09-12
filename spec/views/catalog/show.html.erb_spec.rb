# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/show' do
  before do
    stub_holding_locations
  end

  context 'when entries describe a scanned resource published using an ARK', js: true do
    it 'renders a viewer' do
      visit '/catalog/4609321'
      expect(page).to have_selector('div#viewer-1')
    end
  end

  context 'when entries describe a scanned map published using an ARK', js: true do
    it 'renders a viewer' do
      visit 'catalog/6109323'
      expect(page).to have_selector('div#viewer-1')
    end
  end

  context 'when entries describe resources published using multiple ARKs', js: true do
    it 'renders multiple viewers' do
      visit '/catalog/3943643'
      expect(page).to have_selector('div#viewer-1')
      expect(page).to have_selector('div#viewer-2')
    end
  end

  context 'when entries describe a set of scanned maps published using ARKs', js: true do
    it 'will display only one viewer for the entire set' do
      visit '/catalog/6868324'

      expect(page).to have_selector('div#viewer-1')
      expect(page).not_to have_selector('div#viewer-2')

      visit '/catalog/6773431'

      expect(page).to have_selector('div#viewer-1')
      expect(page).not_to have_selector('div#viewer-2')
    end
  end

  describe 'the location for physical holdings', js: true do
    context 'if physical holding information is recorded in the entry' do
      it 'is not rendered' do
        visit 'catalog/857469'
        expect(page).not_to have_selector('#doc_857469 > dl > dt.blacklight-holdings_1display')
      end
    end

    it 'is rendered' do
      visit 'catalog/6010813'
      expect(page).to have_selector('#doc_6010813 > dl > dt.blacklight-holdings_1display')
    end
  end
end
