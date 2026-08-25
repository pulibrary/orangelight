# frozen_string_literal: true
require 'rails_helper'

describe Orangelight::PipeFacetCheckboxItemPresenter do
  it 'replaces ||| with a dash' do
    filter_field = instance_double(Blacklight::SearchState::FilterField, include?: true)
    presenter = described_class.new(
      Blacklight::Solr::Response::Facets::FacetItem.new(value: 'Dogs|||Australian Cattle Dog', hits: 400),
      Blacklight::Configuration::FacetField.new(key: 'animal_s'),
      CatalogController.new.view_context,
      filter_field,
      instance_double(Blacklight::SearchState, filter: filter_field)
    )

    expect(presenter.label).to eq 'Dogs — Australian Cattle Dog'
  end
end
