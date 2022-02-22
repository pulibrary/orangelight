# frozen_string_literal: true

require 'rails_helper'

describe 'Numismatics show page', type: :system, js: false do
  before do
    stub_holding_locations
    visit '/catalog/coin-3750'
  end

  it 'includes the correct nuismatics fields in top fields' do
    expect(page).to have_selector '.top-fields > .blacklight-numismatic_collection_s'
    expect(page).not_to have_selector '.top-fields > .blacklight-issue_references_s'
  end

  context 'Show page details section' do
    it 'puts the numismatics fields in the correct order' do
      rendered_details_fields = page.all(:css, '.document-details dt').map(&:text)
      expected_details_fields = ["Notes", "Object Type", "Denomination", "Metal",
                                 "Region", "State", "City", "Ruler", "Date",
                                 "Obverse Figure Description", "Obverse Legend",
                                 "Obverse Attributes",
                                 "Reverse Figure Description", "Reverse Legend",
                                 "Series", "References"]
      expect(rendered_details_fields).to eq(expected_details_fields)
    end
  end

  context 'Show page coin details section' do
    it 'puts the numismatics fields in the correct order' do
      rendered_coin_fields = page.all(:css, '.coin-details dt').map(&:text)
      expected_coin_fields = ["Size", "Die Axis", "Weight", "Accession",
                              "Find Place", "Find Number", "Find Date",
                              "Find Locus", "Find Feature",
                              "Statement on Language in Description"]
      expect(rendered_coin_fields).to eq(expected_coin_fields)
    end
  end
end
