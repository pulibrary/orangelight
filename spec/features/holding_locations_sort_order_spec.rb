# frozen_string_literal: true

require 'rails_helper'
# See issue https://github.com/pulibrary/orangelight/issues/2660
# Do we still need this sort when there are recap holdings?
context 'viewing record with multiple holdings' do
  it 'shows east asian holding before recap holding' do
    stub_holding_locations
    visit '/catalog/9938615393506421'
    locations = all('.location-text').map(&:text)
    expect(locations).to eq ["ReCAP - Remote Storage", "East Asian Library - Reference"]
  end
end
