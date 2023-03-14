# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormatFieldComponent, type: :component do
  let(:format) { %w[Dissertation Manuscript Book] }
  let(:document) do
    {
      id: '1',
      format:
    }.with_indifferent_access
  end
  let(:view_context) { controller.view_context }
  let(:field_config) { Blacklight::Configuration::Field.new(key: 'format', field: 'format', label: 'Format') }

  let(:field) do
    Blacklight::FieldPresenter.new(view_context, document, field_config)
  end

  let(:component) { described_class.new(field:, layout: IndexMetadataFieldLayoutComponent) }
  describe '#format_render' do
    it 'returns list of formats separated by comma' do
      expect(component.format_render).to include(format.join(', '))
    end
  end

  describe '#format_icon' do
    before do
      render_inline(component)
    end
    it 'returns icon span for first format' do
      expect(component.format_icon).to include('icon-dissertation')
    end
    it 'does not returns icon span for remaining formats' do
      expect(component.format_icon).not_to include('icon-book')
      expect(component.format_icon).not_to include('icon-manuscript')
    end
  end
  describe 'output' do
    it 'includes the icon and label for the first format' do
      expect(render_inline(component).css('li').inner_html.to_s.strip).to eq '<span class="icon icon-dissertation" aria-hidden="true"></span> Dissertation, Manuscript, Book'
    end
  end
end
