# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ViewerComponent, type: :component do
  let(:manifest_paths_json) do
    {
      'iiif_manifest_paths' => {
        'ephemera_ark' => 'https://example.com/iiif/manifest/1',
        'ephemera_ark1' => 'https://example.com/iiif/manifest/2'
      }
    }.to_json
  end

  context 'with valid electronic_access_1display' do
    it 'returns manifest URLs' do
      component = described_class.new(electronic_access_1display: manifest_paths_json)
      expect(component.manifest_url).to eq([
                                             'https://example.com/iiif/manifest/1',
                                             'https://example.com/iiif/manifest/2'
                                           ])
    end
  end
end
