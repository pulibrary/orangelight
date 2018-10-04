# frozen_string_literal: true

require 'rails_helper'

describe CatalogHelper do
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    allow(helper).to receive_messages(blacklight_config: blacklight_config)
  end

  describe '#render_search_to_page_title_filter' do
    it 'generates the text for faceted search filters' do
      expect(helper.render_search_to_page_title_filter('format', ['book'])).to eq 'Format: book'
      expect(helper.render_search_to_page_title_filter(:format, [:book])).to eq 'Format: book'
    end

    context 'when no values are given for fields being faceted in the search' do
      it 'generates the text for faceted search filters' do
        expect(helper.render_search_to_page_title_filter('format', nil)).to eq ''
        expect(helper.render_search_to_page_title_filter(:format, [])).to eq ''
      end
    end
  end

  describe '#render_search_to_page_title' do
    let(:params) do
      ActionController::Parameters.new(
        f: {
          format: :book,
          location: :ReCAP
        }
      )
    end

    it 'generates the text from the faceted search filters' do
      expect(helper.render_search_to_page_title(params)).to eq 'Format: 4 selected / Location: 5 selected'
    end

    context 'when no values are given for fields being faceted in the search' do
      let(:params) do
        ActionController::Parameters.new(
          f: {
            format: nil,
            location: ''
          }
        )
      end

      it 'generates the text from the faceted search filters' do
        expect(helper.render_search_to_page_title(params)).to eq ''
      end
    end
  end
end
