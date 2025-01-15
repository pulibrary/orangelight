# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::OnOrder, requests: true do
  let(:user) { FactoryBot.create(:user) }
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        on_order?: true,
        charged?: false,
        in_process?: false,
        alma_managed?: true,
        aeon?: false
      )

      eligibility = described_class.new(requestable:, user:)

      expect(eligibility.eligible?).to be(true)
    end
    it 'returns false if the item is not on order' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        on_order?: false,
        alma_managed?: true,
        aeon?: false,
        charged?: false,
        in_process?: false
      )

      eligibility = described_class.new(requestable:, user:)

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
          on_order?: true,
          charged?: false,
          in_process?: false,
          alma_managed?: true,
          aeon?: false
        )

        eligibility = described_class.new(requestable:, user:)

        expect(eligibility.eligible?).to be(true)
      end
    end
  end
end
