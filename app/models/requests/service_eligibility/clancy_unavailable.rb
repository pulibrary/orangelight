# frozen_string_literal: true
module Requests
  module ServiceEligibility
    class ClancyUnavailable
      def initialize(requestable:, user:)
        @requestable = requestable
        @user = user
      end

      def to_s
        'clancy_unavailable'
      end

      def eligible?
        requestable_eligible? && user_eligible?
      end

    private

      def user_eligible?
        user.cas_provider? || user.alma_provider?
      end

      def requestable_eligible?
        requestable.item_at_clancy? && !requestable.clancy_available? &&
          requestable.held_at_marquand_library? &&
          !(requestable.recap? || requestable.recap_pf?) &&
          !requestable.annex? &&
          !requestable.on_order? &&
          !requestable.in_process? &&
          !requestable.charged? &&
          (requestable.alma_managed? || requestable.partner_holding?) &&
          !requestable.aeon?
      end
      attr_reader :requestable, :user
    end
  end
end
