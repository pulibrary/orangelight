# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::AdvancedSearchFormComponent, type: :component do
  subject(:render) do
    component.render_in(view_context)
  end

  let(:component) { described_class.new(url: '/whatever', response:, params:) }
  let(:response) { Blacklight::Solr::Response.new({ facet_counts: { facet_fields: { format: { 'Book' => 10, 'CD' => 5 } } } }.with_indifferent_access, {}) }
  let(:params) { {} }

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:view_context) { controller.view_context }

  before do
    allow(view_context).to receive(:facet_limit_for).and_return(nil)
  end

  it "renders something useful" do
    expect(rendered).to have_field 'clause_0_field', with: 'all_fields', type: :hidden
  end
end
