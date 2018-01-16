# frozen_string_literal: true

require 'rails_helper'

describe 'searching' do
  before do
    stub_holding_locations
  end

  it 'renders an accessible search button' do
    visit '/catalog'
    expect(page).to have_selector '.glyphicon-search[aria-hidden="true"]'
  end

  it 'renders an accessible link to the stack map' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.glyphicon-map-marker[aria-hidden="true"]'
  end

  it 'renders an accessible icon for item icons' do
    visit '/catalog?q=&search_field=all_fields'
    expect(page).to have_selector '.blacklight-format .icon[aria-hidden="true"]'
  end

  context 'with items which are from aeon locations' do
    it 'renders an accessible icon for requesting an item on-site' do
      visit '/catalog?f%5Bformat%5D%5B%5D=Journal'
      expect(page).to have_selector '.icon-request-reading-room[aria-hidden="true"]'
    end
  end
end
