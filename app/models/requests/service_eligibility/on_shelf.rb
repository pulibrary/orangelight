# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request a specific physical resource that is
    # on the shelf
    class OnShelf
      def initialize(requestable:, user:)
        @requestable = requestable
        @user = user
      end

      def to_s
        'on_shelf'
      end

      def eligible?
        requestable_is_eligible? && user_is_eligible?
      end

        private

          def requestable_is_eligible?
            (requestable.alma_managed? || requestable.partner_holding?) &&
              !requestable.online? && !requestable.aeon? &&
              !requestable.charged? && !requestable.in_process? &&
              !requestable.on_order? && !requestable.annex? &&
              !(requestable.recap? || requestable.recap_pf?) &&
              !requestable.held_at_marquand_library? &&
              requestable.circulates?
          end

          def user_is_eligible?
            user.cas_provider? || user.alma_provider?
          end
          attr_reader :requestable, :user
    end
  end
end
