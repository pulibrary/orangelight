# frozen_string_literal: true
module Requests
  module ServiceEligibility
    class MarquandInLibrary
      def initialize(requestable:, patron:)
        @requestable = requestable
        @patron = patron
      end

      def to_s
        'marquand_in_library'
      end

      def eligible?
        requestable_eligible? && patron_group_eligible? && !patron.guest?
      end

    private

      def patron_group_eligible?
        patron.core_patron_group? || (patron.affiliate_patron_group? && !requestable.held_at_marquand_library?)
      end

      def requestable_eligible?
        requestable.held_at_marquand_library? &&
          !(requestable.recap? || requestable.recap_pf?) &&
          !requestable.annex? &&
          !requestable.on_order? &&
          !requestable.in_process? &&
          !requestable.charged? &&
          (requestable.alma_managed? || requestable.partner_holding?) &&
          !requestable.aeon?
      end
      attr_reader :requestable, :patron
    end
  end
end
