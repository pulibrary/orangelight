# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::BrowsablesController, type: :controller do
  describe 'facet' do
    it 'returns vocab_param when browsing subjects' do
      allow(controller).to receive(:browsing_subjects?).and_return(true)
      allow(controller).to receive(:vocab_param).and_return('aat_genre_facet')
      allow(controller).to receive(:model_param).and_return(Orangelight::Subject)
      expect(controller.send(:facet)).to eq('aat_genre_facet')
    end
  end

  describe 'vocab_param' do
    it 'returns the vocab param from the request' do
      allow(controller).to receive(:params).and_return({ vocab: 'aat_genre_facet' })
      expect(controller.send(:vocab_param)).to eq('aat_genre_facet')
    end

    it 'returns nil if vocab param is not present' do
      allow(controller).to receive(:params).and_return({ "q" => "Karaca, Teoman", "model" => Orangelight::Name, "controller" => "orangelight/browsables", "action" => "index" })
      expect(controller.send(:vocab_param)).to be_nil
    end
  end

  describe '#vocabulary_search_on_facet' do
    it 'returns the correct facet for a given vocab type' do
      vocab_types = {
        'Library of Congress subject heading' => 'lc_subject_facet',
        'Library of Congress genre/form terms for library and archival materials' => 'lcgft_genre_facet',
        'Art & architecture thesaurus' => 'aat_genre_facet',
        'Homosaurus terms' => 'homoit_subject_facet',
        'Homosaurus genres' => 'homoit_genre_facet',
        'Rare books genre term' => 'rbgenr_genre_facet',
        'Chinese traditional subjects' => 'siku_subject_facet',
        'Locally assigned term' => 'local_subject_facet'
      }.invert

      vocab_types.each do |vocab, facet|
        allow(controller).to receive(:vocab_param).and_return(vocab)
        expect(controller.send(:vocabulary_search_on_facet)).to eq(facet)
      end
    end
  end
end
