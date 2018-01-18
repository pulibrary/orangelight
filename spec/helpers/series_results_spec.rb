# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#same_series_result' do
    let(:series_title) { 'Monthly Serial' }
    let(:volume_title) { 'Monthly Serial; V. 13' }
    let(:volume_title_2) { 'Monthly Serial; V. 14' }
    let(:non_standard_title) { 'The Monthly Serial; V. 13.' }
    let(:series_display) { [volume_title, volume_title_2, non_standard_title] }
    let(:same_series) { helper.same_series_result(series_title, series_display) }

    it 'excludes non-standardized title' do
      expect(same_series).not_to include(non_standard_title)
    end

    it 'includes all titles that start with the series name' do
      expect(same_series).to include(volume_title, volume_title_2)
    end
  end
end
