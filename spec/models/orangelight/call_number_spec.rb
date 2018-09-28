# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::CallNumber do
  subject(:call_number) { described_class.new(attributes) }

  let(:label) { 'M3 .G32 1972q' }
  let(:sort) { StringFunctions.cn_normalize(label) }
  let(:attributes) do
    {
      label: label,
      sort: sort
    }
  end

  describe '#<=>' do
    let(:label2) { 'M3 G32 2017q vol. 5' }
    let(:sort2) { StringFunctions.cn_normalize(label2) }
    let(:call_number_2) { described_class.new(label: label2, sort: sort2) }

    it 'compares two CallNumbers by the #sorted attribute' do
      expect(call_number <=> call_number_2).to eq(-1)
      expect(call_number_2 <=> call_number).to eq(1)
    end
  end
end
