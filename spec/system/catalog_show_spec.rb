# frozen_string_literal: true

require 'rails_helper'

# describe 'Viewing Catalog Documents', type: :system, js: true do
#   let(:availability_fixture_path) { File.join(fixture_path, 'bibdata', 'availability.json') }
#   let(:availability_fixture) { File.read(availability_fixture_path) }

#   before do
#     stub_holding_locations
#   end

#   # context 'when the Document references a Figgy Resource' do
#   #   let(:solr_url) { Blacklight.connection_config[:url] }
#   #   let(:solr) { RSolr.connect(url: solr_url) }
#   #   let(:document_id) { '9946093213506421' }
#   #   let(:document_fixture_path) { Rails.root.join('spec', 'fixtures', 'alma', "#{document_id}.json") }
#   #   let(:document_fixture_content) { File.read(document_fixture_path) }
#   #   let(:document_fixture) { JSON.parse(document_fixture_content) }

#   #   before do
#   #     solr.add(document_fixture)
#   #     solr.commit
#   #   end

#   #   # it 'renders the thumbnail using the IIIF Manifest' do
#   #   #   visit "catalog/#{document_id}"

#   #   #   using_wait_time 60 do
#   #   #     expect(page).to have_selector("#sidebar > a > div")
#   #   #     # div_class = find('.document-thumbnail.has-viewer-link')
#   #   #     # expect(page).to have_selector ".document-thumbnail.has-viewer-link"
#   #   #     # expect(div_class["data-bib-id"]).to eq document_id
#   #   #   end

#   #   # end

#   #   # redundant spec we are testing the same behavior in spec/views/catalog/show.html.erb_spec
#   #   # it 'renders the IIIF Manifest viewer' do
#   #   #   visit "catalog/#{document_id}"
#   #   #   expect(page).to have_selector('div#viewer-container')
#   #   #   node = page.find("div#view")
#   #   #   expect(node["data-bib-id"]).not_to be_empty
#   #   #   expect(node["data-bib-id"]).to eq document_id
#   #   # end
#   # end
# end
