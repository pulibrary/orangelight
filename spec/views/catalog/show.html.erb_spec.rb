# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/show' do
  before do
    stub_holding_locations
  end

  describe 'Document thumbnail tag' do
    before do
      visit '/catalog/4609321'
    end
    it 'has a document-thumbnail class' do
      expect(page).to have_selector('div.document-thumbnail')
    end
  end

  # it 'renders more than one IIIF viewers if the iiif_manifest_paths exist' do
  #   visit '/catalog/3943643'
  #   expect(page).to have_selector('div#view')
  #   expect(page).to have_selector('div#view_1')
  # end

  # it 'renders one viewer for one iiif_manifest_path ark' do
  #   visit '/catalog/4609321'
  #   expect(page).to have_selector('div#view')
  # end

  # describe 'Ajax based on bibid arks', js: true, type: :request do
  #   context 'mapset' do
  #     it 'will display one viewer from 2 arks, one is suppressed' do
  #       visit '/catalog/6868324'
  #       expect(page.find('#ark_array_id')['data-ark']).to eq('["ark:/88435/2j62s638c", "ark:/88435/t722hb52k"]')
  #       expect(page).to render_template(partial: '_viewer_uv')
  #       expect(page).to have_selector('div#view')
  #     end

  #     it 'will display one viewer from multiple arks' do
  #       visit '/catalog/6773431'
  #       expect(page.find('#ark_array_id')['data-ark']).to eq('["ark:/88435/8336h435c", "ark:/88435/4b29b8439"]')
  #       expect(page).to have_selector('#ark_array_id')
  #       expect(page).to render_template(partial: '_viewer_uv')
  #       expect(page).to have_selector('div#view')
  #     end
  #   end

  #   it 'will display one viewer from one ark' do
  #     visit 'catalog/6109323'
  #     expect(page.find('#ark_array_id')['data-ark']).to eq('["ark:/88435/0v8382995"]')
  #     expect(page).to have_selector('#ark_array_id')
  #     expect(page).to render_template(partial: '_viewer_uv')
  #     expect(page).to have_selector('div#view')
  #   end

  #   it 'will display 2 viewers from two arks' do
  #     visit 'catalog/3943643z'
  #     expect(page.find('#ark_array_id')['data-ark']).to eq('["ark:/88435/np193c809", "ark:/88435/kw52jc00n"]')
  #     expect(page).to have_selector('#ark_array_id')
  #     expect(page).to render_template(partial: '_viewer_uv')
  #     expect(page).to have_selector('div#view')
  #     expect(page).to have_selector('div#view_1')
  #   end
  # end

  describe 'Location_has field in main column', js: true do
    it 'does not display if physical holdings are present' do
      visit 'catalog/857469'
      expect(page).not_to have_selector('#doc_857469 > dl > dt.blacklight-holdings_1display')
    end

    it 'displays if physical holdings are not present' do
      visit 'catalog/6010813'
      expect(page).to have_selector('#doc_6010813 > dl > dt.blacklight-holdings_1display')
    end
  end
end
