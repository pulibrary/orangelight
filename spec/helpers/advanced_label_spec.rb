# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightHelper do
  class MockConfig
    include Blacklight::SearchFields
    include AdvancedHelper
  end

  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.add_search_field('author') do |field|
        field.include_in_advanced_search = true
        field.label = 'Author/Creator'
      end
    end
  end

  let(:config) { MockConfig.new }

  describe '#advanced_key_value' do
    it 'returns label based on field configuration' do
      allow(config).to receive(:blacklight_config).and_return(blacklight_config)
      expect(blacklight_config.search_fields['author'].label).to eq config.advanced_key_value[0][0]
    end
  end
end
