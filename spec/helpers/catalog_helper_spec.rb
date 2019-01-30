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
  #   def render_top_field?(document, field, field_name)
  #   !should_render_show_field?(document, field) && document[field_name].present? &&
  #     field_name != 'holdings_1display'
  # end
  describe '#render_top_field?' do
    let(:field_name) { 'top_field' }
    let(:other_field_name) { 'other_field' }
    let(:holding_field) { 'holdings_1display' }
    let(:field) { blacklight_config.show_fields.first[1] }
    let(:document) { SolrDocument.new(properties) }
    let(:properties) do
      {
        field_name => 'important',
        holding_field => '{}'
      }
    end

    it 'returns true when catalog controller if option is set to false' do
      blacklight_config.add_show_field field_name, if: false
      expect(helper.render_top_field?(document, field, field_name)).to eq true
    end

    it 'returns false when field name is not configured with if option' do
      blacklight_config.add_show_field field_name
      expect(helper.render_top_field?(document, field, field_name)).to eq false
    end

    it 'returns false when field name is configured but field not present in document' do
      blacklight_config.add_show_field other_field_name, if: false
      expect(helper.render_top_field?(document, field, other_field_name)).to eq false
    end

    it 'returns false for holding field' do
      blacklight_config.add_show_field holding_field, if: false
      expect(helper.render_top_field?(document, field, holding_field)).to eq false
    end
  end
end
