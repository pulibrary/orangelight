# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::SortNormalize do
  it 'removes punctuation and spaces' do
    normalizer = described_class.new
    expect(normalizer.normalize('World War, 1939-1945—Occupied territories—Pictorial works')).to eq 'world war 19391945 occupied territories pictorial works'
    expect(normalizer.normalize('Ζουργός, Ισίδωρος, 1964-')).to eq 'ζουργοσ ισιδωροσ 1964' # Note that this uses the incorrect sigma (if we were displaying, we would use Iσίδωρος)
    expect(normalizer.normalize('دراسات. علوم الادارية.')).to eq 'دراسات علوم الادارية'
  end
  it 'folds the German double s into two lower case s characters' do
    normalizer = described_class.new
    expect(normalizer.normalize('程士廉. 帝妃春ßK')).to eq '程士廉 帝妃春ssk'
  end
  it 'removes latin diacritics' do
    normalizer = described_class.new
    expect(normalizer.normalize('Şengönül, Fatma Betül. Kent diplomasisi')).to eq 'sengonul fatma betul kent diplomasisi'
    expect(normalizer.normalize('Vilaça, Aparecida, 1958-. Ficções amazônicas')).to eq 'vilaca aparecida 1958 ficcoes amazonicas'
    expect(normalizer.normalize('Ødegård, Guro. Ungdommen')).to eq 'odegard guro ungdommen'
  end
  it "normalizes Cyrillic characters" do
    normalizer = described_class.new
    expect(normalizer.normalize('Қайранбай, Жұмабай Қожақынұлы. Жұлдызжирен')).to eq 'қайранбай жұмабай қожақынұлы жұлдызжирен'
  end
  it "normalizes Armenian characters" do
    normalizer = described_class.new
    expect(normalizer.normalize('Քոչար՝ Երվանդ, 1899-1979. Works')).to eq 'քոչար երվանդ 18991979 works'
  end
end
