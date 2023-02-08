# frozen_string_literal: true

require 'rails_helper'

describe 'stackmap', type: :system, js: true do
  before do
    stub_holding_locations
    allow(Flipflop).to receive(:firestone_locator?).and_return(false)
  end

  it 'has a link to the stackmap on the record page' do
    visit '/catalog/99125428126306421'
    expect(page).to have_button('Map it', wait: 5)
    click_button 'Map it'
    expect(page).to have_button('zoom in')
    expect(page).to have_no_link('Where to find it')
  end

  it 'has a link to the stackmap on the search results page' do
    visit '/catalog?search_field=all_fields&q='
    expect(page).to have_button('Map it', wait: 5)
    expect(page).to have_no_link('Where to find it')
  end
end
