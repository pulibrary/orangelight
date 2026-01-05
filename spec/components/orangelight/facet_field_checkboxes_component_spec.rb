# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::FacetFieldCheckboxesComponent, type: :component do
  let(:paginator) do
    instance_double(Blacklight::FacetPaginator, items: [
                      double(label: 'a', hits: 10, value: 'a'),
                      double(label: 'b', hits: 33, value: 'b'),
                      double(label: 'c', hits: 3, value: 'c')
                    ])
  end
  let(:search_state) { Blacklight::SearchState.new({}.with_indifferent_access, Blacklight::Configuration.new) }
  let(:items) { [{ label: "Book", value: 'Book', hits: 20 }] }
  let(:display_facet) do
    instance_double(Blacklight::Solr::Response::Facets::FacetField, name: 'field', items:, limit: nil, sort: :index, offset: 0, prefix: nil)
  end
  let(:facet_field) do
    instance_double(
      Blacklight::FacetFieldPresenter,
      display_facet:,
      facet_field: Blacklight::Configuration::NullField.new(key: 'field', item_component: Blacklight::FacetItemComponent, item_presenter: Blacklight::FacetItemPresenter),
      paginator:,
      key: 'field',
      label: 'Field',
      active?: false,
      collapsed?: false,
      modal_path: nil,
      search_state:
    )
  end
  it 'renders a visible facet label' do
    expect(
      render_inline(described_class.new(facet_field:)).to_s
    ).to include(
      "Field"
    )
  end
  context 'when url includes a facet value that the user has selected' do
    let(:search_state) { Blacklight::SearchState.new({ "f_inclusive" => { "field" => ["b"] } }, Blacklight::Configuration.new) }
    it 'displays the value as selected' do
      expect(
        render_inline(described_class.new(facet_field:)).to_s
      ).to include(
        '{"value":"b","selected":true,"label":"b  (33)"}'.gsub('"', '&quot;')
      )
    end
  end
  context 'when url includes multiple facet values that the user has selected' do
    let(:search_state) { Blacklight::SearchState.new({ "f_inclusive" => { "field" => ["b", "c"] } }, Blacklight::Configuration.new) }
    it 'displays both values as selected', js: true do
      expect(
        render_inline(described_class.new(facet_field:)).to_s
      ).to include(
        '{"value":"b","selected":true,"label":"b  (33)"}'.gsub('"', '&quot;')
      )
      expect(
        render_inline(described_class.new(facet_field:)).to_s
      ).to include(
        '{"value":"c","selected":true,"label":"c  (3)"}'.gsub('"', '&quot;')
      )
    end
  end
end
