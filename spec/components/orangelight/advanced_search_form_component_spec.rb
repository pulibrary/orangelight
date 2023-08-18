# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::AdvancedSearchFormComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end
  let(:component) { described_class.new(url: '/whatever', response: , params:) }

  let(:response) do
    Blacklight::Solr::Response.new({}.with_indifferent_access, {})
    # Blacklight::Solr::Response.new({ facet_counts: { facet_fields: {
    #   issue_object_type_s: { 'badge' => 4, 'counterfeit' => 10 },
    #   issue_denomination_s: { '1 Qian' => 4, '1 and 1/3 dollar' => 10 },
    #   issue_metal_s: { 'Brass' => 10 },
    #   issue_city_s: { 'Aleppo' => 10, 'Amul' => 2 },
    #   issue_state_s: { 'Andalusia' => 10, 'Antioch' => 2 },
    #   issue_region_s: { 'Brazil' => 10 },
    #   issue_ruler_s: { 'Alexios III Angelos' => 3 },
    #   issue_artists_s: { 'Ada Possesse' => 1 },
    #   find_place_s: { 'Kushan, India' => 1 }
    # } } }.with_indifferent_access, {})
  end

  let(:params) { {} }

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:view_context) { controller.view_context }

  before do
    allow(view_context).to receive(:facet_limit_for).and_return(nil)
  end

  it "renders fields in the correct order" do
    expected_order = [
      "Keyword", "Title", "Author/Creator", "Subject", "Title starts with", 
      "Publisher", "Notes", "Series title", "ISBN", "ISSN"
    ]
    expect(rendered.all('label').map(&:text)).to match_array(expected_order)
  end
end
