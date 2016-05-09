require 'rails_helper'

RSpec.describe ApplicationHelper do
  let(:format) { ['Dissertation', 'Manuscript', 'Book'] }
  let(:format_display) { helper.format_icon(field_config) }
  let(:render_format) { helper.format_render(field_config) }
  let(:document) do
    {
      id: '1',
      format: format
    }.with_indifferent_access
  end

  let(:field_config) do
    {
      field: :format,
      document: document
    }.with_indifferent_access
  end

  describe '#render_format' do
    it 'returns list of formats separated by comma' do
      expect(render_format).to include(format.join(', '))
    end
  end

  describe '#format_icon' do
    it 'returns icon span for first format' do
      expect(format_display).to include('icon-dissertation')
    end
    it 'does not returns icon span for remaining formats' do
      expect(format_display).not_to include('icon-book')
      expect(format_display).not_to include('icon-manuscript')
    end
  end

  # blacklight_config.view_config(document_index_view_type).display_type_field]
  describe CatalogHelper do
    # let(:blacklight_config) do
    # end
    it '#render_document_class includes only first format' do
      allow(helper).to receive(:document_types).and_return(format)
      document_class = helper.render_document_class(document)
      expect(document_class).to eq('blacklight-dissertation')
    end
  end
end
