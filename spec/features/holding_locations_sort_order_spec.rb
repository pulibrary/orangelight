require 'rails_helper'

context 'viewing record with multiple holdings' do
  it 'shows east asian holding before recap holding' do
    visit '/catalog/3861539'
    locations = all('.location-text').map(&:text)
    expect(locations).to eq ['East Asian Library - Reference', 'ReCAP']
  end
end
