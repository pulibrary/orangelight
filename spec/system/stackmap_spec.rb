# frozen_string_literal: true

require 'rails_helper'

describe 'stackmap', type: :system, js: true do
  before do
    stub_holding_locations
    allow(Flipflop).to receive(:firestone_locator?).and_return(false)
  end

  it 'has a link to the stackmap' do
    visit '/catalog/99125428126306421'
    expect(page).to have_link('Where to find it')
    click_link('Where to find it')
    expect(page).to have_selector('.stackmap-src')
    within_frame(page.find('.stackmap-src')) do
      expect(page).to have_selector('#map')
      expect(page).to have_button('Zoom Out')
    end
  end
end
