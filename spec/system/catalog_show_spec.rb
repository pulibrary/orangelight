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
end
