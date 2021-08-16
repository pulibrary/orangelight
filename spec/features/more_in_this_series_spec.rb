# frozen_string_literal: true

require 'rails_helper'

context 'viewing record with series title' do
  before { stub_holding_locations }

  it 'does not appear for 490 series titles' do
    visit '/catalog/9955253113506421'
    expect(page.all('a.more-in-series').length).to eq 0
  end
  it 'link to search for 8xx series titles' do
    visit '/catalog/9946871913506421'
    expect(page.all('a.more-in-series').length).to eq 2
    all('a.more-in-series').first.click
    expect(page.body).to include('/catalog/9946871913506421')
  end
end
