# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:format) { %w[Dissertation Manuscript Book] }
  let(:format_display) { helper.format_icon(field_config) }
  let(:render_format) { helper.format_render(field_config) }
  let(:document) do
    {
      id: '1',
      format:
    }.with_indifferent_access
  end

  let(:field_config) do
    {
      field: :format,
      document:
    }.with_indifferent_access
  end

  describe '#render_format' do
    it 'returns list of formats separated by comma' do
      expect(render_format).to include(format.join(', '))
    end
  end

  describe CatalogHelper do
    it '#render_document_class includes only first format' do
      allow(helper).to receive(:document_types).and_return(format)
      document_class = helper.render_document_class(document)
      expect(document_class).to eq('blacklight-dissertation')
    end
  end
end
