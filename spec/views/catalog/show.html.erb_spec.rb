# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/show' do
  before do
    stub_holding_locations
  end

  it 'renders more than one IIIF viewers if they exist' do
    visit '/catalog/3943643'
    expect(page).to have_selector('div#view')
    expect(page).to have_selector('div#view_1')
  end

  it 'renders one viewer for one ark' do
    visit '/catalog/4609321'
    expect(page).to have_selector('div#view')
  end
end
