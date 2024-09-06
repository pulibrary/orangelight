# frozen_string_literal: true
module Requests
  module ServiceEligibility
    class AbstractOnShelf
      def initialize(requestable:, user:)
        @requestable = requestable
        @user = user
      end

      def to_s
        raise "Please implement to_s in the subclass"
      end

      def eligible?
        requestable_eligible? && user_eligible?
      end

        protected

          def requestable_eligible?
            raise "Please implement requestable_eligible? in the subclass"
          end

          def on_shelf_eligible?
            !requestable.aeon? && !requestable.charged? &&
              !requestable.in_process? &&
              !requestable.on_order? && !requestable.annex? &&
              !(requestable.recap? || requestable.recap_pf?) &&
              !requestable.held_at_marquand_library?
          end

          def user_eligible?
            user.cas_provider? || user.alma_provider?
          end

          attr_reader :requestable, :user
    end
  end
end
