# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::SortNormalize do
  it 'removes punctuation and spaces' do
    normalizer = described_class.new
    expect(normalizer.normalize('World War, 1939-1945—Occupied territories—Pictorial works')).to eq 'world war 19391945 occupied territories pictorial works'
    expect(normalizer.normalize('Ζουργός, Ισίδωρος, 1964-')).to eq 'ζουργοσ ισιδωροσ 1964' # Note that this uses the incorrect sigma (if we were displaying, we would use Iσίδωρος)
    expect(normalizer.normalize('دراسات. علوم الادارية.')).to eq 'دراسات علوم الادارية'
  end
  it 'removes latin diacritics' do
    normalizer = described_class.new
    expect(normalizer.normalize('Şengönül, Fatma Betül. Kent diplomasisi')).to eq 'sengonul fatma betul kent diplomasisi'
    expect(normalizer.normalize('Vilaça, Aparecida, 1958-. Ficções amazônicas')).to eq 'vilaca aparecida 1958 ficcoes amazonicas'
    expect(normalizer.normalize('Ødegård, Guro. Ungdommen')).to eq 'odegard guro ungdommen'
  end
end
