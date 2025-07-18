# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormatBadgeFieldComponent, type: :component do
  let(:rendered) do
    Capybara::Node::Simple.new(render_inline(described_class.new(field:)))
  end
  let(:document) { SolrDocument.new 'format' => ['Journal', 'Microform'] }
  let(:field_config) { Blacklight::Configuration::Field.new key: 'format', field: 'format', label: 'Format' }

  let(:field) do
    Blacklight::FieldPresenter.new vc_test_controller.view_context, document, field_config
  end

  it 'includes all formats' do
    expect(rendered.text).to include('Journal')
    expect(rendered.text).to include('Microform')
  end
end
