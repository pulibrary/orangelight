# frozen_string_literal: true

require 'rails_helper'

describe Orangelight::BrowsablesHelper, browse: true do
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
  describe '#vocab_type' do
    it 'returns the correct vocab type for a given vocab' do
      expect(helper.vocab_type('Library of Congress subject heading')).to eq('lc_subject_facet')
      expect(helper.vocab_type('Library of Congress genre/form terms for library and archival materials')).to eq('lcgft_genre_facet')
      expect(helper.vocab_type('Art & architecture thesaurus')).to eq('aat_genre_facet')
      expect(helper.vocab_type('Homosaurus terms')).to eq('homoit_subject_facet')
      expect(helper.vocab_type('Homosaurus genres')).to eq('homoit_genre_facet')
      expect(helper.vocab_type('Rare books genre term')).to eq('rbgenr_genre_facet')
      expect(helper.vocab_type('Chinese traditional subjects')).to eq('siku_subject_facet')
      expect(helper.vocab_type('Locally assigned term')).to eq('local_subject_facet')
    end

    it 'returns subject_facet for an unknown vocab' do
      expect(helper.vocab_type('Unknown vocab')).to eq('subject_facet')
    end
  end
end
