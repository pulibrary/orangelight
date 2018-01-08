# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightHelper do
  class MockConfig
    include Blacklight::SearchFields
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_search_field('browse_subject') do |field|
        field.include_in_advanced_search = false
        field.label = 'Subject (browse)'
      end
      config.add_search_field('browse_name') do |field|
        field.include_in_advanced_search = false
        field.label = 'Author (browse)'
        field.placeholder_text = 'Last name, first name'
      end
    end
  end

  let(:config) { MockConfig.new }

  describe '#placeholder_text' do
    it 'returns placeholder text value when present' do
      allow(config).to receive(:blacklight_config).and_return(blacklight_config)
      expect(placeholder_text(config.search_field_def_for_key('browse_name'))).to eq 'Last name, first name'
    end

    it 'returns default placeholder text value when not defined' do
      allow(config).to receive(:blacklight_config).and_return(blacklight_config)
      expect(placeholder_text(config.search_field_def_for_key('browse_subject'))).to include(I18n.t('blacklight.search.form.search.placeholder'))
    end
  end
end
