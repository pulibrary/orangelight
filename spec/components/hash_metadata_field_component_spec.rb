# frozen_string_literal: true
require 'rails_helper'

RSpec.describe HashMetadataFieldComponent, type: :component do
  it 'uses the rendering pipeline' do
    field_config = Blacklight::Configuration::Field.new(key: 'field')
    document = SolrDocument.new({ field: { 'Woof woof!': ['Dog'], 'Meow!': ['Cat'] }.to_json })
    processor = Class.new(Blacklight::Rendering::AbstractStep) do
      def render = values.map { it == 'Dog' ? '🐕' : it }
    end
    operations = [processor]

    component = described_class.new(field_config:, solr_field_name: 'field', document:, operations:)
    rendered = render_inline(component)

    expect(rendered.css('dt').map(&:text)).to eq(['Woof woof!', 'Meow!'])
    expect(rendered.css('dd').map(&:text)).to eq(['🐕', 'Cat'])
  end
end
