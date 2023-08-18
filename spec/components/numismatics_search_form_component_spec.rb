# frozen_string_literal: true

require "rails_helper"

RSpec.describe NumismaticsSearchFormComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:component) { described_class.new(url: '/whatever', response:, params:) }
  let(:response) do
    Blacklight::Solr::Response.new({ facet_counts: { facet_fields: {
      issue_object_type_s: { 'badge' => 4, 'counterfeit' => 10 },
      issue_denomination_s: { '1 Qian' => 4, '1 and 1/3 dollar' => 10 },
      issue_metal_s: { 'Brass' => 10 },
      issue_city_s: { 'Aleppo' => 10, 'Amul' => 2 },
      issue_state_s: { 'Andalusia' => 10, 'Antioch' => 2 },
      issue_region_s: { 'Brazil' => 10 },
      issue_ruler_s: { 'Alexios III Angelos' => 3 },
      issue_artists_s: { 'Ada Possesse' => 1 },
      find_place_s: { 'Kushan, India' => 1 }
    } } }.with_indifferent_access, {})
  end
  let(:params) { {} }

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:view_context) { controller.view_context }

  before do
    allow(view_context).to receive(:facet_limit_for).and_return(nil)
  end

  it "renders all expected fields" do
    expected_fields = [
      'Object Type', 'Denomination', 'Metal', 'City', 'State',
      'Region', 'Ruler', 'Artist', 'Find Place', 'Year',
      'date range (starting year)', 'date range (ending year)',
      'Keyword', 'Sort results by'
    ]
    expect(rendered.all('label').map(&:text)).to match_array(expected_fields)
  end

  context 'when URL includes facet params from the user' do
    let(:params) do
      { "f_inclusive" => { "issue_ruler_s" => ["Alexios III Angelos"] } }.with_indifferent_access
    end
    let(:filter) do
      facet_config = CatalogController.blacklight_config.facet_fields['issue_ruler_s']
      search_state = Blacklight::SearchState.new(params, CatalogController.blacklight_config)
      [Blacklight::SearchState::FilterField.new(facet_config, search_state)]
    end
    before do
      allow_any_instance_of(Blacklight::SearchState).to receive(:filters).and_return(filter)
    end
    it "displays the constraints area" do
      constraints_area = rendered.find('.constraints')
      expect(constraints_area).to have_text('Ruler:Alexios III Angelos')
    end
  end
end
