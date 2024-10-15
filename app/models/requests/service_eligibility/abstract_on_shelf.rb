# frozen_string_literal: true
module Requests
  module ServiceEligibility
    class AbstractOnShelf
      def initialize(requestable:, user:, patron: nil)
        @requestable = requestable
        @user = user
        @patron = patron
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
              !requestable.on_order? &&
              requestable.alma_managed? &&
              !(requestable.recap? || requestable.recap_pf?) &&
              !requestable.held_at_marquand_library?
          end

          def provider_eligible?
            user.cas_provider? || user.alma_provider?
          end

          def patron_group_eligible?
            allowed_patron_groups = %w[P REG GRAD SENR UGRAD]
            allowed_patron_groups.include?(patron.patron_group)
          end

          def user_eligible?
            provider_eligible? && patron_group_eligible?
          end

          attr_reader :requestable, :user, :patron
    end
  end
end
