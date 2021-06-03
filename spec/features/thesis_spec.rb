# frozen_string_literal: true

require 'rails_helper'

describe 'Viewing on-site thesis record' do
  it 'provides link to Mudd website' do
    stub_holding_locations
    visit  '/catalog/dsp01tq57ns24j'
    within 'dd.blacklight-restrictions_note_display' do
      find_link 'Mudd Manuscript Library'
    end
  end
  context 'when using Alma' do
    context 'for theses with physical locations' do
      # It uses a thesis fixture from fixtures/alma/current_fixtures.json
      before do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
        stub_holding_locations
        visit  '/catalog/dsp01wd3760321'
      end
      it 'has link to Mudd website' do
        within 'dd.blacklight-restrictions_note_display' do
          find_link 'Mudd Manuscript Library'
        end
        find('span', text: 'Mudd Manuscript Library')
      end
      it 'has a span with Mudd alma location name' do
        find('span', text: 'Mudd Manuscript Library')
      end
    end
    context 'with online thesis' do
      # It uses a thesis fixture from fixtures/alma/current_fixtures.json
      before do
        stub_holding_locations
        visit '/catalog/dsp01w6634604k'
      end
      it 'does not have a location class' do
        expect(page).not_to have_css('location-services service-conditional')
      end
      it 'has an available online section with an ark identifier lookup ' do
        link = page.find('.electronic-access > a')
        expect(link[:href]).to include('https://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/ark:')
      end
    end
  end
end
