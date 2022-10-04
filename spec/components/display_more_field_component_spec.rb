# frozen_string_literal: true

require "rails_helper"

RSpec.describe DisplayMoreFieldComponent, type: :component do
  let(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(field: field)))
  end
  let(:document) { SolrDocument.new('field' => (1..10).map { |i| "Chapter #{i}" }) }
  let(:field_config) { Blacklight::Configuration::Field.new(key: 'field', field: 'field', label: 'Field label') }

  let(:field) do
    Blacklight::FieldPresenter.new(controller.view_context, document, field_config)
  end

  it 'renders the field label' do
    expect(rendered).to have_selector 'dt.blacklight-field', text: 'Field label'
  end
  it 'renders a list' do
    expect(rendered).to have_selector('li', count: 10)
  end
end
