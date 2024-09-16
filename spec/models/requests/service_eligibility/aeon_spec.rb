# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Aeon, requests: true do
  describe '#eligible?' do
    it 'returns true if Alma-managed and aeon true' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        alma_managed?: true,
        aeon?: true
      )
      eligibility = described_class.new(requestable:)

      expect(eligibility.eligible?).to be(true)
    end
  end
end
