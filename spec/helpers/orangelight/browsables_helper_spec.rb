# frozen_string_literal: true

require 'rails_helper'

describe Orangelight::BrowsablesHelper do
  let(:integer_bib) { '234267' }
  let(:non_integer_bib) { '?f[call_number_browse_s][]=PRIN 685 2015' }
  let(:scsb_bib) { 'SCSB-8096576' }

  describe '#should_check_availability?' do
    it 'returns true when bibid argument is an integer string' do
      expect(helper.should_check_availability?(integer_bib)).to eq(true)
    end
    it 'returns false when bibid argument is not an integer string' do
      expect(helper.should_check_availability?(non_integer_bib)).to eq(false)
    end
    it 'returns false when bibid arguement is a SCSB bib' do
      expect(helper.should_check_availability?(scsb_bib)).to eq(false)
    end
  end
  describe '#bib_for_availability' do
    it 'returns the original bib id if it is an integer string' do
      expect(helper.bib_for_availability(integer_bib)).to eq(integer_bib)
    end
    it 'returns 0 if the original bib is not an integer string' do
      expect(helper.bib_for_availability(non_integer_bib)).to eq('0')
    end
  end
end
