# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request a specific resource via ILL
    class ILL
      def initialize(requestable:, patron:, any_loanable:)
        @requestable = requestable
        @any_loanable = any_loanable
        @patron = patron
      end

      def to_s
        'ill'
      end

      def eligible?
        requestable_eligible? && patron_group_eligible? && !patron.guest?
      end

        private

          def requestable_eligible?
            !requestable.aeon? && (requestable.charged? || requestable.requested?) && !requestable.marquand_item? &&
              (!any_loanable || requestable.enumerated? || requestable.preservation_conservation?)
          end

          def patron_group_eligible?
            patron.core_patron_group?
          end

          attr_reader :requestable, :any_loanable, :patron
    end
  end
end
