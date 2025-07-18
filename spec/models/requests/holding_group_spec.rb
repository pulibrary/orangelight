# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::HoldingGroup do
  describe 'sorting for display' do
    it 'sorts branch libraries before remote locations' do
      architecture = described_class.new(group_name: 'Architecture Library - Stacks', holdings: [])
      remote = described_class.new(group_name: 'Remote Storage (ReCAP): Historic Maps. Special Collections Use Only', holdings: [])

      expect(architecture).to be < remote
      expect(remote).to be > architecture
    end
  end
end
