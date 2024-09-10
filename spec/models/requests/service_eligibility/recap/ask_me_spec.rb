# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Recap::AskMe, requests: true do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        scsb_in_library_use?: true,
        eligible_for_library_services?: false
      )
      eligibility = described_class.new(requestable:)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if criteria are not met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        recap?: true,
        scsb_in_library_use?: true,
        eligible_for_library_services?: true
      )
      eligibility = described_class.new(requestable:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
