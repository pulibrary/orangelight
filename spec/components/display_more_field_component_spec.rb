# frozen_string_literal: true

require "rails_helper"

RSpec.describe DisplayMoreFieldComponent, type: :component do
  subject(:rendered) do
    byebug
    Capybara::Node::Simple.new(render_inline(described_class.new(field: field)))
  end
  view_context = let(:view_context) { instance_double(ActionView::Base) }
  let(:document) { SolrDocument.new('field' => (1..10).map{|i| "Chapter #{i}"}) }
  let(:field_config) { Blacklight::Configuration::Field.new(key: 'field', field: 'field', label: 'Field label') }


  let(:field) do
    Blacklight::FieldPresenter.new(controller.view_context, document, field_config)
  end

  it 'renders the field label' do
    expect(rendered).to have_selector 'dt.blacklight-field', text: 'Field label'
  end
end
