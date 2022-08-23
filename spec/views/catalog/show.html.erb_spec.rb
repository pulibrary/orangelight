# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/show' do
  before do
    stub_holding_locations
  end

  context 'when entries describe a scanned resource published using an ARK', js: true do
    xit 'renders a viewer' do
      visit '/catalog/9946093213506421'
      expect(page).to have_selector('div#viewer-container')
    end
  end

  context 'when entries describe a scanned map published using an ARK', js: true do
    xit 'renders a viewer' do
      visit 'catalog/9961093233506421'
      expect(page).to have_selector('div#viewer-container')
    end
  end

  context 'when entries describe resources published using multiple ARKs', js: true do
    xit 'renders multiple viewers' do
      visit '/catalog/9970446223506421'
      expect(page).to have_selector('div#viewer-container')
      expect(page).to have_selector('div#viewer-container_1')
    end
  end

  context 'when entries describe a set of scanned maps published using ARKs', js: true do
    xit 'will display only one viewer for the entire set' do
      visit '/catalog/9968683243506421'
      expect(page).to have_selector('div#viewer-container')
    end
  end

  xit 'renders the thumbnail using the IIIF Manifest' do
    visit "catalog/9946093213506421"
    expect(page).to have_selector("#.document-thumbnail.has-viewer-link", wait: 60)

    # using_wait_time 60 do
    #   expect(page).to have_selector("#sidebar > a > div")
    #   # div_class = find('.document-thumbnail.has-viewer-link')
    #   # expect(page).to have_selector ".document-thumbnail.has-viewer-link"
    #   # expect(div_class["data-bib-id"]).to eq document_id
    # end
  end

  context 'when entries describe a coin', js: true do
    xit 'will render a viewer when coins are in figgy production' do
      visit 'catalog/coin-2'
      expect(page).to have_selector('div#viewer-container')
    end
  end

  context 'for coins with monograms' do
    xit 'will render a monogram thumbnail with figgy production coins', js: true do
      visit 'catalog/coin-1167'
      expect(page).to have_selector('div#view') # REVIEW: the monogram spec. The viewer has div#viewer-container
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

  describe 'the hathi url' do
    it 'has a link to the hathi url' do
      visit 'catalog/998574693506421'
      expect(page).not_to have_link('Temporary Digital Access from Hathi Trust', href: 'https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3Dmdp.39015015749305')
    end
  end

  context 'when a document has Chinese traditional subjects' do
    it "displays them" do
      visit 'catalog/9970446223506421'
      expect(page).to have_content('Chinese traditional subject(s)')
      expect(page).to have_content('Zi bu')
    end
  end

  context 'when a document has Homosaurus subjects' do
    it 'displays them' do
      visit 'catalog/99125412083106421'
      expect(page).to have_content('Homosaurus term(s)')
      expect(page).to have_content('LGBTQ chosen families')
    end
  end

  context 'when a document has no language_iana_s' do
    it 'defaults to lang attribute "en"' do
      visit 'catalog/99124945733506421'
      header_title = find(:xpath, "//*[@id='content']/div[1]/h1")
      expect(header_title['lang']).to eq 'en'
    end
  end
  context 'when a document has italian as a primary language' do
    it 'has lang attribute "it"' do
      visit 'catalog/99125428126306421'
      header_title = find(:xpath, "//*[@id='content']/div[1]/h1")
      expect(header_title['lang']).to eq 'it'
    end
  end
  context 'when there is a vernacular title and a heading title' do
    it 'has a lang attribute in both headers' do
      visit 'catalog/9990660953506421'

      vernacular_title = find(:xpath, "//*[@id='content']/div[1]/h1[1]")
      expect(vernacular_title['lang']).to eq 'ru'

      header_title = find(:css, "#content > div.col-12.header-row > h1:nth-child(3)")
      expect(header_title['lang']).to eq 'ru'
    end
  end

  context 'when the indexes and supplements array are empty' do
    it 'does not display indexes or supplements statements' do
      visit 'catalog/997218033506421'
      expect(page).not_to have_selector('.holding-supplements')
      expect(page).not_to have_selector('.holding-indexes')
    end
  end
  context 'when indexes is not included in the holdings JSON' do
    it 'does not display indexes statements' do
      visit 'catalog/9957223113506421'
      expect(page).not_to have_selector('.holding-indexes')
    end
  end
  context 'when indexes is included in the holdings JSON' do
    it 'displays indexes statement' do
      visit 'catalog/995597013506421'
      expect(page).to have_selector('.holding-indexes')
    end
  end
  context 'when using keyboard' do
    it 'user can activate bookmark button', js: true do
      visit 'catalog/995597013506421'
      expect(page).to have_content('Bookmark')
      expect { press_element('.bookmark-button') }.not_to raise_exception(Selenium::WebDriver::Error::ElementNotInteractableError)
      expect(page).to have_content('Remove bookmark')
    end
  end
  describe 'menus' do
    it 'only has menu elements that contain menuitems' do
      visit 'catalog/995597013506421'
      expect(page).to have_content('Send to')
      all_menus = page.all(:css, '[role=menu]')
      all_menus.each do |menu|
        menu.assert_any_of_selectors(:css, "[role=menuitem]", "[role=menuitemcheckbox]", "[role=menuitemradio]")
      end
      send_to_menu = page.find(:xpath, '//*[@id="main-container"]/div/div[2]/div[1]/div/div[2]/ul/li[2]/ul')
      expect(send_to_menu['role']).to be_nil
    end
  end
end
