# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'catalog/_show_digital_content.html.erb', :viewer, type: :view do
  let(:electronic_access_json) do
    '{"https://figgy.princeton.edu/catalog/fa30780e-dfd8-4545-b1b0-b3eec9fca96b":["Online Content","Born Digital Monographic Reports and Papers"],"https://catalog-staging.princeton.edu/catalog/fa30780e-dfd8-4545-b1b0-b3eec9fca96b#view":["Digital content"],"iiif_manifest_paths":{"ephemera_ark":"https://figgy.princeton.edu/concern/scanned_resources/f4ca996b-cd14-4179-aa4d-acd35edcc840/manifest","ephemera_ark1":"https://figgy.princeton.edu/concern/scanned_resources/465998ec-5dd4-4dd8-a0fe-0934008b9df8/manifest"}}'
  end

  let(:document) do
    instance_double(SolrDocument,
                    id: 'fa30780e-dfd8-4545-b1b0-b3eec9fca96b',
                    uuid?: true,
                    related_bibs_iiif_manifest: [],
                    present?: true)
  end

  before do
    allow(document).to receive(:[]).with('electronic_access_1display').and_return(electronic_access_json)
    assign(:document, document)
  end

  it 'renders the ephemera viewer when uuid and electronic_access_1display are present' do
    render partial: 'catalog/show_digital_content', locals: { document: document }
    expect(rendered).to have_css('#view.document-viewers[data-bib-id="fa30780e-dfd8-4545-b1b0-b3eec9fca96b"]')
    expect(rendered).to include('https://figgy.princeton.edu/concern/scanned_resources/f4ca996b-cd14-4179-aa4d-acd35edcc840/manifest')
    expect(rendered).to include('https://figgy.princeton.edu/concern/scanned_resources/465998ec-5dd4-4dd8-a0fe-0934008b9df8/manifest')
  end
end
