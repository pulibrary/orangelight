# frozen_string_literal: true

require 'rails_helper'

describe 'Facets' do
  before { stub_holding_locations }

  context 'with facets rendered' do
    it 'renders only a subset of all the facets on the homepage' do
      visit '/catalog'
      home_facets = page.all('.facet-limit').length
      visit '/catalog?search_field=all_fields&q=Great+Britain'
      search_facets = page.all('.facet-limit').length
      expect(home_facets).to be < search_facets
    end

    it 'renders accessible facets' do
      visit '/catalog'
      expect(page).to have_selector '.facet-values .icon[aria-hidden="true"]', minimum: 10
    end
  end

  context 'it has accessible facets' do
    before do
      visit '/catalog'
    end
    it 'card-header in facet-panel-collapse has button with aria-expanded' do
      a_tag_first = find(:xpath, "//*[@id='facet-panel-collapse']/div[1]/h3/button")
      expect(a_tag_first['aria-expanded']).to be_truthy
    end
    it 'when keydown Enter on <button> tag it toggles the aria-expanded value', js: true do
      a_tag_first = find(:xpath, "//*[@id='facet-panel-collapse']/div[1]/h3/button")
      expect(a_tag_first['aria-expanded']).to eq "true"
      a_tag_first.native.send_keys(:enter)
      expect(a_tag_first['aria-expanded']).to eq "false"
    end
    it 'when keydown Space on <button> tag it toggles the aria-expanded value', js: true do
      a_tag_first = find(:xpath, "//*[@id='facet-panel-collapse']/div[1]/h3/button")
      expect(a_tag_first['aria-expanded']).to eq "true"
      a_tag_first.native.send_keys(:space)
      expect(a_tag_first['aria-expanded']).to eq "false"
    end
    it 'when keydown Return <button> tag it toggles the aria-expanded value', js: true do
      a_tag_first = find(:xpath, "//*[@id='facet-panel-collapse']/div[1]/h3/button")
      expect(a_tag_first['aria-expanded']).to eq "true"
      a_tag_first.native.send_keys(:return)
      expect(a_tag_first['aria-expanded']).to eq "false"
    end
  end

  context 'with advanced limits' do
    it 'will render when clicked from the record' do
      visit  '/catalog/3'
      click_link 'Advanced Search'
      click_link I18n.t('blacklight.advanced_search.form.start_over')
    end
  end

  context 'advanced search only facets', js: true do
    it 'will hide facets not configured for advanced search display' do
      visit '/catalog/?f[format][]=Book'
      expect(page.all('.blacklight-advanced_location_s').length).to eq 0
      expect(page.all('.blacklight-location').length).to eq 1
      click_link I18n.t('blacklight.search.edit_search')
      expect(page.all('#location').length).to eq 0
      expect(page.all('#advanced_location_s').length).to eq 1
      expect(page.all('#access_facet').length).to eq 1
    end
  end

  describe 'publication date facet' do
    describe 'it has a submit button' do
      it 'shows a large version of the slider' do
        visit '/?f[format][]=Book'
        click_button 'Publication year'
        expect(page).to have_selector('.submit')
      end
    end
  end

  describe 'with blacklight-hierarchy gem' do
    context 'with the hierarchical classification facet with pipes' do
      before do
        allow(Flipflop).to receive(:blacklight_hierarchy_facet?).and_return(false)
      end
      it 'renders the classification facet' do
        visit '/catalog?search_field=all_fields&q='
        expect(page).to have_selector('.blacklight-lc_pipe_facet')
        # Displays all 17 LC single letter classes
        within('.blacklight-lc_pipe_facet') do
          expect(page.all('.h-node').length).to eq(17)
          # The A class contains two subclasses
          expect(page.first('.h-node').all('.h-leaf').length).to eq(3)
        end
      end
    end
    context 'with the hierarchical classification facet' do
      before do
        allow(Flipflop).to receive(:blacklight_hierarchy_facet?).and_return(true)
      end
      it 'renders the classification facet' do
        visit '/catalog?search_field=all_fields&q='
        expect(page).to have_selector('.blacklight-lc_facet')
        # Displays all 17 LC single letter classes
        within('.blacklight-lc_facet') do
          expect(page.all('.h-node').length).to eq(17)
          # The A class contains two subclasses
          expect(page.first('.h-node').all('.h-leaf').length).to eq(3)
        end
      end
    end
    context 'with the hierarchical place of publication facet with pipes' do
      before do
        allow(Flipflop).to receive(:blacklight_hierarchy_publication_facet?).and_return(false)
      end
      it 'renders the place of publication facet' do
        visit '/catalog?search_field=all_fields&q='
        expect(page).to have_selector('.blacklight-publication_place_hierarchical_pipe_facet')
        # Displays all 3 place of publication classes
        within('.blacklight-publication_place_hierarchical_pipe_facet') do
          expect(page.all('.h-node').length).to eq(3)
          # The A class contains two subclasses
          expect(page.all('.h-node')[2].all('.h-leaf').length).to eq(7)
        end
      end
    end
    context 'with the hierarchical place of publication facet' do
      before do
        allow(Flipflop).to receive(:blacklight_hierarchy_publication_facet?).and_return(true)
      end
      it 'renders the place of publication facet' do
        visit '/catalog?search_field=all_fields&q='
        expect(page).to have_selector('.blacklight-publication_place_hierarchical_facet')
        # Displays all 3 place of publication classes
        within('.blacklight-publication_place_hierarchical_facet') do
          expect(page.all('.h-node').length).to eq(3)
          # The A class contains two subclasses
          expect(page.all('.h-node')[2].all('.h-leaf').length).to eq(7)
        end
      end
    end
  end
end
