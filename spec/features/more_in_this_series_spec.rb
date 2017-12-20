require 'rails_helper'

context 'viewing record with series title' do
  before { stub_holding_locations }

  it 'does not appear for 490 series titles' do
    visit '/catalog/5525311'
    expect(page.all('a.more-in-series').length).to eq 0
  end
  it 'link to search for 8xx series titles' do
    visit '/catalog/4687191'
    expect(page.all('a.more-in-series').length).to eq 2
    all('a.more-in-series').first.click
    expect(page.body).to include('/catalog/4687191')
  end
end
