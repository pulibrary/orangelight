# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::ServiceEligibility::MarquandPageChargedItem, :requests do
  describe '#eligible?' do
    it 'returns true if all criteria are met' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        held_at_marquand_library?: true,
        item_at_clancy?: false,
        alma_managed?: true,
        aeon?: false,
        charged?: true,
        in_process?: false,
        on_order?: false,
        recap?: false
      )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(true)
    end

    it 'does not consider in_process items eligible' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        held_at_marquand_library?: true,
        item_at_clancy?: false,
        alma_managed?: true,
        aeon?: false,
        charged?: false,
        in_process?: true,
        on_order?: false,
        recap?: false
      )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(false)
    end

    it 'does not consider on_order items eligible' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        held_at_marquand_library?: true,
        item_at_clancy?: false,
        alma_managed?: true,
        aeon?: false,
        charged?: false,
        in_process?: false,
        on_order?: true,
        recap?: false
      )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(false)
    end

    it 'can consider clancy items eligible' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        held_at_marquand_library?: false,
        item_at_clancy?: true,
        alma_managed?: true,
        aeon?: false,
        charged?: true,
        in_process?: false,
        on_order?: false,
        recap?: false
      )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(true)
    end

    it 'does not consider non-Marquand items eligible' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        held_at_marquand_library?: false,
        item_at_clancy?: false,
        alma_managed?: true,
        aeon?: false,
        charged?: true,
        in_process?: false,
        on_order?: false,
        recap?: false
      )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(false)
    end

    it 'does not consider non-charged items eligible' do
      requestable = instance_double(Requests::Requestable)
      allow(requestable).to receive_messages(
        held_at_marquand_library?: true,
        item_at_clancy?: false,
        alma_managed?: true,
        aeon?: false,
        charged?: false,
        in_process?: false,
        on_order?: false,
        recap?: false
      )
      eligibility = described_class.new(requestable:, user: FactoryBot.create(:user))

      expect(eligibility.eligible?).to be(false)
    end
  end
end
