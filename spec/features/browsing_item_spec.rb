# frozen_string_literal: true

require 'rails_helper'

describe 'browsing a catalog item' do
  before do
    stub_holding_locations
  end

  it 'renders an accessible icon for citing the item' do
    visit 'catalog/3478898'
    expect(page).to have_selector '.icon-cite[aria-hidden="true"]'
  end

  it 'renders an accessible icon for sending items to a printer' do
    visit 'catalog/3478898'
    expect(page).to have_selector '.icon-share[aria-hidden="true"]'
    expect(page).to have_selector '.icon-print[aria-hidden="true"]'
  end

  context 'for Voyager items' do
    it 'renders an accessible icon in the link to the Voyager record' do
      visit 'catalog/9222024'
      expect(page).to have_selector '.glyphicon-share-alt[aria-hidden="true"]'
    end
  end
end
