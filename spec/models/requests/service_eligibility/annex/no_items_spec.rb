# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::Annex::NoItems, requests: true do
  let(:user) { FactoryBot.create(:user) }
  describe '#eligible?' do
    let(:patron) { instance_double(Requests::Patron, core_patron_group?: true) }
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        item_data?: false,
        annex?: true
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(true)
    end

    it 'returns false if criteria are not met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        item_data?: true,
        annex?: true
      )
      eligibility = described_class.new(requestable:, patron:)

      expect(eligibility.eligible?).to be(false)
    end
  end
end
