# frozen_string_literal: true

require "rails_helper"

RSpec.describe IndexMetadataFieldLayoutComponent, type: :component do
  context 'when you pass this component to a Blacklight::MetadataFieldComponent' do
    let(:metadata_component) do
      field = instance_double(Blacklight::FieldPresenter, label: 'my label', render: 'my value', render_field?: true)
      Blacklight::MetadataFieldComponent.new(field:, layout: described_class)
    end
    it "displays the field's value" do
      expect(render_inline(metadata_component).to_html).to include('my value')
    end
    it "does not display the field's label" do
      expect(render_inline(metadata_component).to_html).not_to include('my label')
    end
  end
end
