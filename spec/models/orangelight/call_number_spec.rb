# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::CallNumber do
  subject(:call_number) { described_class.new(attributes) }

  let(:attributes) do
    {
      label: 'Z342 .M48 1988'
    }
  end

  describe '.sort_by_label_date' do
    let(:call_number_2) { described_class.new(label: 'Z342 .M48 1990') }
    let(:call_number_1) { described_class.new(label: 'Z342 .M48 1988') }
    let(:call_numbers) do
      [
        call_number_2,
        call_number_1
      ]
    end
    let(:sorted_call_numbers) { described_class.sort_by_label_date(call_numbers) }

    it 'sorts by label dates' do
      expect(sorted_call_numbers).not_to be_empty
      expect(sorted_call_numbers.length).to eq(2)
      expect(sorted_call_numbers.first).to eq(call_number_1)
      expect(sorted_call_numbers.last).to eq(call_number_2)
    end
  end

  describe '#label_date' do
    let(:label_date) { Date.parse('1988-01-01') }

    it 'constructs a Date from the label attribute' do
      expect(call_number.label_date).to eq(label_date)
    end

    context 'when the label does not contain a date' do
      let(:attributes) do
        {
          label: 'Z342 .M48'
        }
      end

      it 'does not construct a Date' do
        expect(call_number.label_date).to be_nil
      end
    end
  end

  describe '#<=>' do
    let(:attributes) do
      {
        sort: 'Z342 .M48 1988'
      }
    end
    let(:call_number_2) { described_class.new(sort: 'Z342 .M48 1990') }

    it 'compares two CallNumbers by the #sorted attribute' do
      expect(call_number <=> call_number_2).to eq(-1)
      expect(call_number_2 <=> call_number).to eq(1)
    end
  end
end
