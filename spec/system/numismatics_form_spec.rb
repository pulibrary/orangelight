# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Numismatics search form' do
  before do
    stub_alma_holding_locations
  end
  context 'when using the view components numismatics form' do
    before { allow(Flipflop).to_receive(:view_components_numismatics?).and_return(true) }
  end
  it 'does not display the basic search form' do
    visit '/numismatics'
    expect(page).not_to have_selector('.search-query-form')
  end
  it 'can run a search' do
    visit '/numismatics'
    select('shekel', from: 'f_inclusive[issue_denomination_s][]')
    click_button('advanced-search-submit')
    expect(page.find(".page_entries").text).to eq('1 entry found')
    expect(page).to have_content('Coin: 1167')
  end

  context 'when using the original numismatics form' do
    before { allow(Flipflop).to_receive(:view_components_numismatics?).and_return(false) }
  end
  it 'does not display the basic search form' do
    visit '/numismatics'
    expect(page).not_to have_selector('.search-query-form')
  end
  it 'can run a search' do
    visit '/numismatics'
    select('shekel', from: 'f_inclusive[issue_denomination_s][]')
    click_button('advanced-search-submit')
    expect(page.find(".page_entries").text).to eq('1 entry found')
    expect(page).to have_content('Coin: 1167')
  end
end
