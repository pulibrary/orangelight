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
  let(:facet_field) do
    instance_double(
      Blacklight::FacetFieldPresenter,
      facet_field: Blacklight::Configuration::NullField.new(key: 'field', item_component: Blacklight::FacetItemComponent, item_presenter: Blacklight::FacetItemPresenter),
      paginator:,
      key: 'field',
      label: 'Field',
      active?: false,
      collapsed?: false,
      modal_path: nil,
      search_state: search_state
    )
  end
  it 'renders a visible facet label' do
    expect(
      render_inline(described_class.new(facet_field:)).to_s
    ).to include(
      "Field"
    )
  end
end
