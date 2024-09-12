# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::AccessPatron, requests: true do
  it 'can be instantiated' do
    described_class.new(session: {})
  end

  describe '#hash' do
    it 'has a hash' do
      expect(described_class.new(session: {}).hash).to be_an_instance_of(HashWithIndifferentAccess)
    end
  end
end
