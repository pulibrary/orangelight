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
    solr.add(document_fixture)
    solr.commit

    stub_holding_locations

    visit "catalog/#{document_id}"
    system("/usr/bin/env siege --internet --concurrent=5 --time=#{siege_time}S --json-output #{target_uri} > #{siege_file.path}")
  end

  after do
    siege_file.close
    siege_file.unlink
  end

  it 'renders the thumbnail using the IIIF Manifest' do
    expect(siege_report).to include("successful_transactions")
    expect(siege_report["successful_transactions"]).to be > 0
    expect(siege_report).to include("failed_transactions")
    expect(siege_report["failed_transactions"]).to be <= 0
  end

  context 'when the Figgy GraphQL responds with a bib. ID' do
    let(:document_id) { '4609321' }

    it 'renders the thumbnail using the IIIF Manifest' do
      expect(siege_report).to include("successful_transactions")
      expect(siege_report["successful_transactions"]).to be > 0
      expect(siege_report).to include("failed_transactions")
      expect(siege_report["failed_transactions"]).to be <= 0
    end
  end
end
