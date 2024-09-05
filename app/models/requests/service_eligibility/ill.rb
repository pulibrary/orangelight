# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request a specific resource via ILL 
    class ILL
      def initialize(requestable:, user:, any_loanable:)
        @requestable = requestable
        @user = user
        @any_loanable = any_loanable
      end

      def to_s
        'ill'
      end

      def eligible?
        requestable_is_eligible? && user_is_eligible?
      end

        private

            def requestable_is_eligible?
                (requestable.alma_managed? || requestable.partner_holding?) &&
                  !requestable.aeon? && !requestable.online? && requestable.charged? &&
                  (!any_loanable || requestable.enumerated? || requestable.preservation_conservation?)
            end

            def user_is_eligible?
                user.cas_provider? || user.alma_provider?
            end

          attr_reader :requestable, :user, :any_loanable
    end
  end
end
