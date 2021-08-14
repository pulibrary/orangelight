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
    let(:solr) do
      RSolr.connect(url: solr_url)
    end
    let(:document_id) do
      '9946093213506421'
    end
    let(:document_fixture_path) do
      Rails.root.join('spec', 'fixtures', 'alma', "#{document_id}.json")
    end
    let(:document_fixture_content) do
      File.read(document_fixture_path)
    end
    let(:document_fixture) do
      JSON.parse(document_fixture_content)
    end

    before do
      solr.add(document_fixture)
      solr.commit
    end

    it 'renders the thumbnail using the IIIF Manifest' do
      visit "catalog/#{document_id}"

      expect(page).to have_selector ".document-thumbnail.has-viewer-link"
      node = page.find(".document-thumbnail.has-viewer-link")
      expect(node["data-bib-id"]).not_to be_empty
      expect(node["data-bib-id"]).to eq document_id
    end

    context 'when the Figgy GraphQL responds with a different bib. ID' do
      let(:document_id) { '9946093213506421' }

      it 'renders the thumbnail using the IIIF Manifest' do
        visit "catalog/#{document_id}"
        expect(page).to have_selector ".document-thumbnail.has-viewer-link"
        node = page.find(".document-thumbnail.has-viewer-link")
        expect(node["data-bib-id"]).not_to be_empty
        expect(node["data-bib-id"]).to eq document_id
      end
    end

    it 'renders the IIIF Manifest viewer with #view as a container <div> element' do
      visit "catalog/#{document_id}"
      expect(page).to have_selector "div#view.document-viewers"
      node = page.find("div#view")
      expect(node["data-bib-id"]).not_to be_empty
      expect(node["data-bib-id"]).to eq document_id
    end
  end
end
