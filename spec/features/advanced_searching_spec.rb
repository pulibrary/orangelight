# frozen_string_literal: true

require 'rails_helper'

describe 'advanced searching' do
  before do
    stub_holding_locations
  end

  it 'renders an accessible button for starting over the search' do
    visit '/advanced'
    expect(page).to have_selector '.icon-refresh[aria-hidden="true"]'
  end
end
