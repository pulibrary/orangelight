# frozen_string_literal: true

require 'rails_helper'

describe 'Load Testing', type: :system, js: true do
  let(:availability_fixture_path) { File.join(fixture_path, 'bibdata', 'availability.json') }
  let(:availability_fixture) { File.read(availability_fixture_path) }
  let(:siege_file) do
    Tempfile.new('siege.json')
  end
  let(:blacklight_connection_config) do
    Blacklight.connection_config
  end
  let(:solr_url) do
    blacklight_connection_config[:url]
  end
  let(:siege_report) do
    JSON.parse(siege_file.read)
  end
  let(:siege_time) do
    10
  end
  let(:solr) { RSolr.connect(url: solr_url) }
  let(:document_id) { '9946093213506421' }
  let(:document_fixture_path) { Rails.root.join('spec', 'fixtures', 'alma', "#{document_id}.json") }
  let(:document_fixture_content) { File.read(document_fixture_path) }
  let(:document_fixture) { JSON.parse(document_fixture_content) }
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
  let(:target_uri) do
    "#{page.server.base_url}/catalog/#{document_id}"
  end

  before do
    stub_holding_locations
  end

  let(:noun_file) do
    Rails.root.join('spec', 'fixtures', 'load_testing_urls', "nouns.txt")
  end

  let(:adj_file) do
    Rails.root.join('spec', 'fixtures', 'load_testing_urls', "adjectives.txt")
  end

  let(:base_url) do
    page.server.base_url
  end

  let(:url_generator) do
    UrlFileGenerator.new(noun_file: noun_file, adj_file: adj_file, base_url: base_url)
  end

  let(:urls) do
    url_generator.generate
  end

  context 'when requesting URLs in series' do
    it "accesses the search results" do
      urls.each do |url|
        visit(url.to_s)
        expect(page).to have_selector('h1', text: "Princeton University Library Catalog")
      end
    end
  end
end
