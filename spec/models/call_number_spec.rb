# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CallNumber do
  describe '#with_line_break_suggestions' do
    it 'adds line break suggestions (<wbr>) before periods' do
      expect(described_class.new('G4312.S6C18.1943.D4I5').with_line_break_suggestions).to eq 'G4312<wbr>.S6C18<wbr>.1943<wbr>.D4I5'
      expect(described_class.new('G4312.S6C18.1943.D4I5').with_line_break_suggestions).to be_html_safe
    end

    it 'removes unnecessary html' do
      expect(described_class.new('G4312<script><p><div>').with_line_break_suggestions).to eq 'G4312'
      expect(described_class.new('G4312<script>alert("HI!")</script>').with_line_break_suggestions).to eq 'G4312'
    end

    it 'returns an empty string if call number label is nil' do
      expect(described_class.new(nil).with_line_break_suggestions).to eq ''
    end
  end
end
