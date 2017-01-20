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
        microfilm_1 = described_class.cn_normalize('MICROFILM 1')
        expect(microfiche..microfilm_1).to cover microfilm
      end
      it 'CD and CD- file the same' do
        expect(described_class.cn_normalize('CD 4032')).to eq described_class.cn_normalize('CD- 4032')
      end
      it 'the number is sorted as an integer' do
        expect(described_class.cn_normalize('18th-25')).to be < described_class.cn_normalize('18th-24000')
      end
    end
  end
end
