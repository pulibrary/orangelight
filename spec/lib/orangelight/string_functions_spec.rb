require 'rails_helper'

RSpec.describe StringFunctions do
  describe '#cn_normalize' do
    describe 'LC call numbers' do
      it 'LC call numbers with a lowercase x normalize the same as cns without it' do
        expect(StringFunctions.cn_normalize('BP190.5.W35 xF3')).to eq StringFunctions.cn_normalize('BP190.5.W35 F3')
      end
      it 'lowercase x remains when it does not immediately precede a cutter letter' do
        expect(StringFunctions.cn_normalize('BP190.5.W35 F3x')).to include('X')
      end
    end

    describe 'accession numbers' do
      it 'alphabetic characters are made upper case' do
        microfiche = StringFunctions.cn_normalize('MICROFICHE')
        microfilm = StringFunctions.cn_normalize('microfilm')
        microfilm_1 = StringFunctions.cn_normalize('MICROFILM 1')
        expect(microfiche..microfilm_1).to cover microfilm
      end
    end
  end
end
