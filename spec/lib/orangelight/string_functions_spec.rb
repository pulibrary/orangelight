# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StringFunctions do
  describe '#cn_normalize' do
    describe 'LC call numbers' do
      it 'LC call numbers with a lowercase x normalize the same as cns without it' do
        expect(described_class.cn_normalize('BP190.5.W35 xF3')).to eq described_class.cn_normalize('BP190.5.W35 F3')
      end
      it 'lowercase x remains when it does not immediately precede a cutter letter' do
        expect(described_class.cn_normalize('BP190.5.W35 F3x')).to include('X')
      end
      it 'valid LC call numbers starting with LC are normalized as such' do
        expect(described_class.cn_normalize('CD102 .D575 2008')).to eq Lcsort.normalize('CD102 .D575 2008')
      end
    end

    describe 'accession numbers' do
      it 'alphabetic characters are made upper case' do
        microfiche = described_class.cn_normalize('MICROFICHE')
        microfilm = described_class.cn_normalize('microfilm')
        microfilm1 = described_class.cn_normalize('MICROFILM 1')
        expect(microfiche..microfilm1).to cover microfilm
      end
      it 'CD and CD- file the same' do
        expect(described_class.cn_normalize('CD 4032')).to eq(described_class.cn_normalize('CD- 4032'))
        expect(described_class.cn_normalize('CD- 4032')).to eq('CD 0004032')
      end
      it 'the number is sorted as an integer' do
        expect(described_class.cn_normalize('18th-25')).to be < described_class.cn_normalize('18th-24000')
      end
      it 'oversize q is ignored' do
        dvd1 = described_class.cn_normalize('DVD 204')
        dvd2 = described_class.cn_normalize('DVD 205q')
        dvd3 = described_class.cn_normalize('DVD 206')
        expect(dvd1..dvd3).to cover dvd2
      end
      it 'ignores the term Oversize as well as the q' do
        expect(described_class.cn_normalize('CD- 40056q')).to eq('CD 0040056')
        expect(described_class.cn_normalize('CD- 40056q Oversize')).to eq('CD 0040056')
      end
      it 'leading zeros normalize the same as without' do
        expect(described_class.cn_normalize('CASSETTE 423')).to eq described_class.cn_normalize('CASSETTE 0423')
      end
    end
  end
end
