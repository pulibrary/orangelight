# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # on_order - material has a status in Alma that indicates it is ordered but has not yet arrived on campus
    class OnOrder
      def initialize(requestable:, patron:)
        @requestable = requestable
        @patron = patron
      end

      def to_s
        'on_order'
      end

      def eligible?
        requestable_eligible? && user_eligible?
      end

      private

        def requestable_eligible?
          (requestable.alma_managed? || requestable.partner_holding?) &&
            !requestable.aeon? &&
            !requestable.charged? &&
            !requestable.in_process? &&
            requestable.on_order?
        end

        def user_eligible?
          patron.core_patron_group?
        end

        attr_reader :requestable, :patron
    end
  end
end
