# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/show' do
  before do
    stub_holding_locations
  end

  context 'when entries describe a scanned resource published using an ARK', js: true do
    it 'renders a viewer' do
      visit '/catalog/9946093213506421'
      expect(page).to have_selector('div#view')
    end
  end

  context 'when entries describe a scanned map published using an ARK', js: true do
    it 'renders a viewer' do
      visit 'catalog/9961093233506421'
      expect(page).to have_selector('#view')
    end
  end

  context 'when entries describe resources published using multiple ARKs', js: true do
    it 'renders multiple viewers' do
      visit '/catalog/9970446223506421'
      expect(page).to have_selector('div#viewer-container')
      expect(page).to have_selector('div#viewer-container_1')
    end
  end

  context 'when entries describe a set of scanned maps published using ARKs', js: true do
    it 'will display only one viewer for the entire set' do
      visit '/catalog/9968683243506421'

      expect(page).to have_selector('div#view')
      expect(page).not_to have_selector('div#view_1')

      visit '/catalog/9967734313506421'

      expect(page).to have_selector('div#view')
      expect(page).not_to have_selector('div#view_1')
    end
  end

  context 'when entries describe a coin', js: true do
    xit 'will render a viewer when coins are in figgy production' do
      visit 'catalog/coin-2'
      expect(page).to have_selector('div#view')
    end
  end

  context 'for coins with monograms' do
    xit 'will render a monogram thumbnail with figgy production coins', js: true do
      visit 'catalog/coin-1167'
      expect(page).to have_selector('div#view')
    end

    it 'displays each monogram label with link to search' do
      visit 'catalog/coin-1167'
      expect(page).to have_link('Archaic Monogram', href: '/?f[issue_monogram_title_s][]=Archaic+Monogram')
      expect(page).to have_link('Phoenician Letter', href: '/?f[issue_monogram_title_s][]=Phoenician+Letter')
    end
  end

  describe 'the location for physical holdings', js: true do
    context 'if physical holding information is recorded in the entry' do
      it 'is not rendered' do
        visit 'catalog/9960108133506421'
        expect(page).not_to have_selector('#doc_9960108133506421 > dl > dt.blacklight-holdings_1display')
      end
    end
    # This seems to have changed. Maybe because we dont display items anymore in the show page?
    xit 'is rendered' do
      visit 'catalog/998574693506421'
      expect(page).to have_selector('#doc_998574693506421 > dl > dt.blacklight-holdings_1display')
    end
  end

  describe 'the issue number' do
    it 'has a link to the issue' do
      visit 'catalog/coin-1'
      expect(page).to have_link('1', href: '/?f[issue_number_s][]=1')
    end
  end

  describe 'the class year' do
    it 'has a link to the class year' do
      visit 'catalog/dsp0141687h654'
      expect(page).to have_link('2014', href: '/?f[class_year_s][]=2014')
    end
  end

  describe 'the hahti url' do
    it 'has a link to the hathi url' do
      visit 'catalog/998574693506421'
      expect(page).not_to have_link('Temporary Digital Access from Hathi Trust', href: 'https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Dmdp.39015015749305')
    end
  end
end
