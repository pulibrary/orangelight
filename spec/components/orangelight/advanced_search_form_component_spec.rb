# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::AdvancedSearchFormComponent, type: :component, advanced_search: true do
  subject(:render) do
    component.render_in(view_context)
  end
  let(:component) { described_class.new(url: '/whatever', response:, params:) }

  let(:response) do
    Blacklight::Solr::Response.new({}.with_indifferent_access, {})
  end

  let(:params) { {} }

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:view_context) { controller.view_context }

  before do
    allow(view_context).to receive(:facet_limit_for).and_return(nil)
  end

  it "has a dropdown with the expected options" do
    expected_options = [
      "Keyword", "Title", "Author/Creator", "Subject", "Title starts with",
      "Publisher", "Notes", "Series title", "ISBN", "ISSN"
    ]
    options = rendered.all('select')[1].all('option').map(&:text)
    expect(options).to eq(expected_options)
  end

  it 'has text fields for each search field' do
    expect(rendered).to have_selector '.advanced-search-field', count: 1
    expect(rendered).to have_field 'clause_0_field', with: 'all_fields'
    expect(rendered).to have_field 'clause_1_field', with: 'author'
    expect(rendered).to have_field 'clause_2_field', with: 'title'
  end
end
