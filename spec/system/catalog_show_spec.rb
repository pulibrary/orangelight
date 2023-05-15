# frozen_string_literal: true

require 'rails_helper'

describe 'Viewing Catalog Documents', type: :system, js: true do
  let(:availability_fixture_path) { File.join(fixture_path, 'bibdata', 'availability.json') }
  let(:availability_fixture) { File.read(availability_fixture_path) }

  before do
    stub_holding_locations
  end

  context 'when the Document references a Figgy Resource' do
    let(:solr_url) { Blacklight.connection_config[:url] }
    let(:solr) { RSolr.connect(url: solr_url) }
    let(:document_id) { '9946093213506421' }
    let(:document_fixture_path) { Rails.root.join('spec', 'fixtures', 'alma', "#{document_id}.json") }
    let(:document_fixture_content) { File.read(document_fixture_path) }
    let(:document_fixture) { JSON.parse(document_fixture_content) }
    let(:solr_url) do
      Blacklight.connection_config[:url]
    end

    before do
      solr.add(document_fixture)
      solr.commit
    end

    xit 'renders the thumbnail using the IIIF Manifest' do
      visit "catalog/#{document_id}"

      expect(page).to have_selector(".document-thumbnail.has-viewer-link")
      node = page.find(".document-thumbnail.has-viewer-link")
      expect(node["data-bib-id"]).to eq document_id
    end

    xit 'renders the IIIF Manifest viewer with #view as a container <div> element' do
      visit "catalog/#{document_id}"
      expect(page).to have_selector('div#viewer-container')
      node = page.find("div#view")
      expect(node["data-bib-id"]).to eq document_id
    end
  end

  context 'related records field' do
    it 'only displays three related records, even when more are in the index' do
      visit 'catalog/99124945733506421'
      expect(page).to have_selector('dd.blacklight-related_record_s ul li', count: 3)
      node = page.find('dd.blacklight-related_record_s button')
      expect(node.text).to eq 'Show 10 more related records'
    end
  end

  context 'uniform title display' do
    let(:solr_url) { Blacklight.connection_config[:url] }
    let(:solr) { RSolr.connect(url: solr_url) }
    let(:document_id) { '9946093213506421' }
    let(:document_fixture_path) { Rails.root.join('spec', 'fixtures', 'alma', "#{document_id}.json") }
    let(:document_fixture_content) { File.read(document_fixture_path) }
    let(:document_fixture) { JSON.parse(document_fixture_content) }

    before do
      solr.add(document_fixture)
      solr.commit
    end

    it 'shows the Uniform title' do
      visit "catalog/#{document_id}"
      # Regular display title
      expect(page).to have_content('Bible, Latin.')
      # Uniform title
      expect(page).to have_content('Uniform title')
      expect(page).to have_content('Bible. Latin. Vulgate. 1456')
      expect(page).to have_link('Bible', href: '/?search_field=left_anchor&q=Bible')
      expect(page).to have_link('Bible. Latin', href: '/?search_field=left_anchor&q=Bible.+Latin')
    end
  end

  context 'multi-valued isbn field' do
    let(:document_id) { '99125535710106421' }

    it 'displays as a list' do
      visit "catalog/#{document_id}"
      expect(page).to have_selector('dd.blacklight-isbn_display ul li', count: 4)
    end
  end

  describe 'giving feedback' do
    let(:document_id) { '9946093213506421' }
    before { allow(Flipflop).to receive(:harmful_content_feedback?).and_return(true) }

    it 'shows a feedback bar' do
      visit "catalog/#{document_id}"
      expect(page).to have_selector('.harmful-content-feedback')
      expect(page).to have_content('Report Harmful Language')
    end

    it 'opens a modal for Ask a Question' do
      visit "catalog/#{document_id}"
      click_on('Ask a Question')
      expect(page).to have_field('Name')
      fill_in('Name', with: 'Test User')
      expect(page).to have_field('Email')
      fill_in('Email', with: 'testuser@test-domain.org')
      expect(page).to have_field('Message')
      fill_in('Message', with: 'Why is the thumbnail wrong?')
      context_field = page.find_field("ask_a_question_form[context]", type: :hidden)
      expect(context_field.value).to include("/catalog/#{document_id}")
      title_field = page.find_field("ask_a_question_form[title]", type: :hidden)
      expect(title_field.value).to eq("Bible, Latin.")
    end

    it 'opens a modal for Suggest a Correction' do
      visit "catalog/#{document_id}"
      click_on('Suggest a Correction')
      expect(page).to have_field('Name')
      fill_in('Name', with: 'Test User')
      expect(page).to have_field('Email')
      fill_in('Email', with: 'testuser@test-domain.org')
      expect(page).to have_field('Message')
      fill_in('Message', with: 'Replace with correct thumbnail.')
      context_field = page.find_field("suggest_correction_form[context]", type: :hidden)
      expect(context_field.value).to include("/catalog/#{document_id}")
      title_field = page.find_field("suggest_correction_form[title]", type: :hidden)
      expect(title_field.value).to eq("Bible, Latin.")
    end

    it 'opens a modal for Report Harmful Language' do
      visit "catalog/#{document_id}"
      click_on('Report Harmful Language')
      expect(page).to have_content('users may encounter offensive or harmful language')
      expect(page).to have_field('Name')
      fill_in('Name', with: 'Test User')
      expect(page).to have_field('Email')
      fill_in('Email', with: 'testuser@test-domain.org')
      expect(page).to have_field('Message')
      fill_in('Message', with: 'I am concerned about this subject heading')
      context_field = page.find_field("report_harmful_language_form[context]", visible: :hidden)
      expect(context_field.value).to include("/catalog/#{document_id}")
      title_field = page.find_field("report_harmful_language_form[title]", visible: :hidden)
      expect(title_field.value).to eq("Bible, Latin.")
    end
  end

  describe 'showing top fields' do
    let(:document_id) { '9946093213506421' }
    let(:top_fields) { ['uniform_title_1display', 'format', 'pub_created_display', 'description_display'] }
    let(:details_fields) do
      ['printer', 'binder', 'former-owner', 'notes_display', 'binding_note_display',
       'provenance_display', 'references_url_display', 'other_format_display',
       'other_title_display', 'recap_notes_display']
    end

    it 'shows top fields in their own section' do
      visit "catalog/#{document_id}"
      within('dl.top-fields') do
        top_fields.each do |field|
          expect(page).to have_selector("dt.blacklight-#{field}")
        end
        details_fields.each do |field|
          expect(page).not_to have_selector("dt.blacklight-#{field}")
        end
      end
      within('dl.document-details') do
        top_fields.each do |field|
          expect(page).not_to have_selector("dt.blacklight-#{field}")
        end
        details_fields.each do |field|
          expect(page).to have_selector("dt.blacklight-#{field}")
        end
      end
    end
    context 'with a record without a format' do
      let(:document_id) { 'SCSB-7935196' }
      it 'does not raise a deprecation warning' do
        allow(Deprecation).to receive(:default_deprecation_behavior).and_return(:raise)
        visit "catalog/#{document_id}"
        within('dl.top-fields') do
          expect(page).to have_selector("dt.blacklight-pub_created_display")
          expect(page).to have_selector("dt.blacklight-description_display")
        end
      end
    end
  end

  describe 'action note display' do
    context 'with the new display' do
      before do
        allow(Flipflop).to receive(:new_action_note_display?).and_return(true)
      end
      context 'when the record does not have a link in the action note' do
        let(:document_id) { '99125628841606421' }

        it 'shows the action note' do
          visit("catalog/#{document_id}")
          expect(page).to have_content("Item processed and described by Kelly Bolding in August 2022, incorporating some description provided by the dealer.").once
          expect(page).not_to have_link("Item processed and described by Kelly Bolding in August 2022, incorporating some description provided by the dealer.")
        end
      end

      context 'when the record has a link in the action note' do
        let(:document_id) { '99126831126106421' }

        it 'shows a linked action note' do
          visit("catalog/#{document_id}")
          expect(page).to have_link('Vol. 1: Committed to retain in perpetuity — ReCAP Italian Language Imprints Collaborative Collection (NjP)')
        end
      end
    end

    context 'with the old display' do
      before do
        allow(Flipflop).to receive(:new_action_note_display?).and_return(false)
      end

      context 'when the record only has a new style action note' do
        let(:document_id) { '99126831126106421' }

        it 'does not show the field' do
          visit("catalog/#{document_id}")
          expect(page).not_to have_content('Action note')
        end
      end
    end
  end

  describe 'Request button' do
    context 'aeon constituent record' do
      it 'links directly to aeon with data about the host and constituent' do
        visit("catalog/9923427953506421")
        expect(page).to have_link('Reading Room Request', href: Regexp.new('https://lib-aeon\.princeton\.edu/aeon/aeon\.dll/OpenURL.*rft\.title=The\+reply\+of\+a\+member\+of\+Parliament.*CallNumber=HJ5118\+\.H4\+1733'))
      end
    end
  end
end
