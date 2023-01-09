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
      context_field = page.find_field("ask_a_question_form[context]", type: :hidden)
      expect(context_field.value).to include("/catalog/#{document_id}")
      title_field = page.find_field("ask_a_question_form[title]", type: :hidden)
      expect(title_field.value).to eq("Bible, Latin.")
    end
  end
end
