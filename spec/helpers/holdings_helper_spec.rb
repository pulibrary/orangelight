# frozen_string_literal: true
require 'rails_helper'

describe 'HoldingsHelper' do
  include ApplicationHelper
  include CatalogHelper
  include HoldingsHelper

  describe '#holding_block_search' do
    it 'uses source_id from holding, then falls back to document id' do
      stub_holding_locations
      document = SolrDocument.new({
                                    id: '12345',
                                    holdings_1display: '{"2222":{"source_id":"67890","location_code":"firstone$stacks"},"3333":{"location_code":"firstone$stacks"}}'
                                  })
      rendered = Nokogiri::HTML.fragment(holding_block_search(document))
      expect(rendered.css('[data-record-id="67890"][data-holding-id="2222"]').length).to eq 1
      expect(rendered.css('[data-record-id="12345"][data-holding-id="3333"]').length).to eq 1
      expect(rendered.css('[data-record-id="12345"][data-holding-id="2222"]')).not_to be_present
    end
  end
end
