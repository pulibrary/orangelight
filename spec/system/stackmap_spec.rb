# frozen_string_literal: true

require 'rails_helper'

describe 'stackmap', type: :system, js: true do
  before do
    stub_holding_locations
  end
  context 'using the stackmap' do
    it 'has a link to the stackmap on the record page' do
      visit '/catalog/99125428126306421'
      click_button('Where to find it', wait: 5)
      expect(page).to have_button('zoom in')
    end
  end
end
