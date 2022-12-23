# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::SearchBarComponent, type: :component do
  let(:component) { described_class.new(url: nil, params: {}) }
  let(:blacklight_config) do
    Blacklight::Configuration.new.configure do |config|
      config.search_fields = {
        'title': Blacklight::Configuration::SearchField.new(label: 'Title', dropdown_label: 'Title (keyword)', key: 'title'),
        'browse_cn': Blacklight::Configuration::SearchField.new(label: 'Call number', dropdown_label: 'Call number (browse)', key: 'browse_cn', placeholder_text: 'e.g. P19.737.3'),
        'oclc': Blacklight::Configuration::SearchField.new(label: 'OCLC', key: 'oclc', include_in_simple_select: false)
      }
    end
  end

  before do
    allow(component).to receive(:blacklight_config).and_return(blacklight_config)
  end

  describe '#search_fields' do
    it 'uses the field dropdown_label when available' do
      expect(component.search_fields).to include(["Title (keyword)", "title", { 'data-placeholder' => I18n.t('blacklight.search.form.search.placeholder') }])
    end

    it 'does not show fields with include_in_simple_select=false' do
      expect(component.search_fields).not_to include(["OCLC", "oclc", { 'data-placeholder' => I18n.t('blacklight.search.form.search.placeholder') }])
    end

    it 'includes a placeholder text if defined' do
      expect(component.search_fields).to include(["Call number (browse)", "browse_cn", { 'data-placeholder' => 'e.g. P19.737.3' }])
    end
  end
end
