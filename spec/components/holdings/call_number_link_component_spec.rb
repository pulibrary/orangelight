# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Holdings::CallNumberLinkComponent, type: :component do
  let :holding do
    { call_number: 'East 45/GC073/Box 06/Oversize' }.with_indifferent_access
  end
  let(:call_number) { 'East 45/GC073/Box 06/Oversize' }
  let :rendered do
    render_inline described_class.new(holding, call_number)
  end

  it 'has a browse link' do
    expect(rendered.css('a').text.strip).to eq 'Call no. browse'
    expect(rendered.css('a').attribute('href').value).to eq '/browse/call_numbers?q=East+45%2FGC073%2FBox+06%2FOversize'
  end

  it 'is a table cell' do
    expect(rendered.css('div').length).to eq 1
  end

  it 'puts the call number in a .call-number class' do
    expect(rendered.css('.call-number').text).to eq 'East 45/GC073/Box 06/Oversize'
  end

  context 'when no call_number is provided' do
    let(:call_number) { nil }
    it 'has no link' do
      expect(rendered.css('a').length).to eq 0
    end

    it 'has no icon' do
      expect(rendered.css('.icon-bookslibrary').length).to eq 0
    end

    it 'has an empty table cell' do
      expect(rendered.css('div').length).to eq 1
      expect(rendered.css('div').text.strip).to eq ''
    end
  end
end
