# frozen_string_literal: true

require 'rails_helper'

describe 'Numismatics Records' do
  before { stub_holding_locations }

  context 'with a full coin record' do
    it 'displays numismatics fields' do
      visit '/catalog/coin-1'

      expect(page).to have_content 'References'
      expect(page).to have_content 'Die Axis'
      expect(page).to have_content 'Obverse Attributes'
      expect(page).to have_content 'Reverse Attributes'
      expect(page).to have_content 'Date'
      expect(page).to have_content 'Artist'
      expect(page).to have_content 'Subject'
      expect(page).to have_content 'Accession'
      expect(page).to have_content 'Provenance'
    end
  end
end
