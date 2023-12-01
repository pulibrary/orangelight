# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Numismatics search form' do
  context 'when using the view components numismatics form' do
    before { allow(Flipflop).to_receive(:view_components_numismatics?).and_return(true) }
  end
  it 'does not display the basic search form' do
    visit '/numismatics'
    expect(page).not_to have_selector('.search-query-form')
  end

  context 'when using the original numismatics form' do
    before { allow(Flipflop).to_receive(:view_components_numismatics?).and_return(false) }
  end
  it 'does not display the basic search form' do
    visit '/numismatics'
    expect(page).not_to have_selector('.search-query-form')
  end
end
