# frozen_string_literal: true

require 'rails_helper'

describe 'Selecting search algorithms for results', type: :system, js: false do
  before do
    stub_holding_locations
  end

  context 'with the search algorithms feature enabled' do
    before do
      allow(Flipflop).to receive(:multi_algorithm?).and_return(true)
    end

    it 'renders a select widget used to select the ordering algorithm' do
      pending("Allowing user to choose ranking algorithm while using the json query dsl.")
      visit '/catalog?search_field=all_fields&q=roman'
      expect(page).to have_text('1. Огонек : роман')

      click_button('Rank by default')
      within('#engineering.dropdown-help-text') do
        expect(page).to have_text("move documents about engineering to the top")
      end
      click_link('engineering')
      expect(page).to have_button('Rank by engineering')
      expect(page).to have_text('1. Reconstructing the Vitruvian Scorpio: An Engineering Analysis')
    end
  end

  context 'with the search algorithms feature disabled' do
    before do
      allow(Flipflop).to receive(:multi_algorithm?).and_return(false)
    end

    it 'does not render a select widget' do
      visit '/catalog?search_field=all_fields&q=roman'
      expect(page).not_to have_button('Rank by default')
    end
  end
end
