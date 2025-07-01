# frozen_string_literal: true

require 'rails_helper'

describe 'stackmap', type: :system, js: true do
  before do
    stub_holding_locations
  end
  context 'using the stackmap' do
    before do
      allow(Flipflop).to receive(:temporary_where_to_find_it?).and_return(false)
    end
    xit 'has a link to the stackmap on the record page' do # Stackmap subscription has lapsed.
      visit '/catalog/99125428126306421'
      click_button('Where to find it', wait: 5)
      expect(page).to have_button('zoom in')
    end
  end

  context 'not using the stackmap' do
    before do
      allow(Flipflop).to receive(:temporary_where_to_find_it?).and_return(true)
    end
    it 'has a link to the stackmap on the record page' do
      visit '/catalog/99125428126306421'
      expect(page).not_to have_button('Where to find it')
    end
  end
end
