# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HoldingRequestsBuilder do
  describe '.missing_holdings' do
    let(:markup) { described_class.missing_holdings }

    it 'generates the markup for the missing holdings <div>' do
      expect(markup).to include '<tr class="holding-block"'
      expect(markup).to include 'There are no holdings available for this record. Please consult a library staff member at the nearest circulation desk.'
    end
  end

  describe '.holding_block' do
    let(:children) { '<div>test1</div><div>test2</div>' }
    let(:markup) { described_class.holding_block(children) }

    it 'generates the markup for a generic <div> container' do
      expect(markup).to include '<tr class="holding-block"'
      expect(markup).to include '<div>test1</div><div>test2</div>'
    end
  end
end
