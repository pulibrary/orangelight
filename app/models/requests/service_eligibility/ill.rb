# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request a specific resource via ILL
    class ILL
      def initialize(requestable:, patron:, any_loanable:)
        @requestable = requestable
        @user = patron.user
        @any_loanable = any_loanable
        @patron = patron
      end

      def to_s
        'ill'
      end

      def eligible?
        requestable_eligible? && user_eligible? && patron_group_eligible?
      end

        private

          def requestable_eligible?
            !requestable.aeon? && requestable.charged? &&
              (!any_loanable || requestable.enumerated? || requestable.preservation_conservation?)
          end

          def user_eligible?
            user.cas_provider? || user.alma_provider?
          end

          def patron_group_eligible?
            allowed_patron_groups.include?(patron.patron_group)
          end

          def allowed_patron_groups
            @allowed_patron_groups ||= %w[P REG GRAD SENR UGRAD]
          end

          attr_reader :requestable, :user, :any_loanable, :patron
    end
  end
end
