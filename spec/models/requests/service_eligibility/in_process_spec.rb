# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::InProcess, requests: true do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: true
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false if the item is not in process' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: false
        )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(false)
    end

    context 'with an alma authenticated user' do
      let(:user) { FactoryBot.create(:guest_patron) }

      it 'returns true' do
        expect(user.guest?).to be false
        expect(user.alma_provider?).to be(true)
        expect(user.cas_provider?).to be(false)
        expect(user.provider).to eq('alma')
        requestable = instance_double(Requests::Requestable)
        allow(requestable).to receive_messages(
          aeon?: false,
          charged?: false,
          in_process?: true
        )

        eligibility = described_class.new(requestable:, user:)

        expect(eligibility.eligible?).to be(true)
      end
    end
  end
end
