# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if the given requestable and user
    # can use a service where Marquand staff retrieve the item from another user's
    # carrel.  The materials in the other user's carrel are charged (checked out),
    # so this service is only possible for charged materials.
    class MarquandPageChargedItem
      def initialize(requestable:, patron:)
        @requestable = requestable
        @patron = patron
      end

      def eligible?
        correct_status? && correct_location? && patron_group_eligible?
      end

      def to_s
        'marquand_page_charged_item'
      end

          private

            def correct_status?
              requestable.charged? && !requestable.in_process? && !requestable.on_order?
            end

            def correct_location?
              requestable.held_at_marquand_library?
            end

            def patron_group_eligible?
              patron.core_patron_group?
            end

            attr_reader :requestable, :patron
    end
  end
end
