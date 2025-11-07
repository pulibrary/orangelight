# frozen_string_literal: true
module Requests
  module ServiceEligibility
    class InProcess
      def initialize(requestable:, patron:)
        @requestable = requestable
        @patron = patron
      end

      def to_s
        'in_process'
      end

      def eligible?
        requestable_eligible? && user_eligible?
      end

    private

      def user_eligible?
        patron.core_patron_group?
      end

      def requestable_eligible?
        !requestable.aeon? && !requestable.charged? && requestable.in_process?
      end
      attr_reader :requestable, :patron
    end
  end
end
