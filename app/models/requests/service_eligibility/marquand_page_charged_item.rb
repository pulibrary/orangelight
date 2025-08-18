# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if the given requestable and user
    # can use a service where Marquand staff retrieve the item from another user's
    # carrel.  The materials in the other user's carrel are charged (checked out),
    # so this service is only possible for charged materials.
    class MarquandPageChargedItem
      def initialize(requestable:, user:)
        @requestable = requestable
        @user = user
      end

      def eligible?
        correct_status? && correct_location? && user_eligible?
      end

      def to_s
        'marquand_page_charged_item'
      end

          private

            def correct_status?
              requestable.charged? && !requestable.in_process? && !requestable.on_order?
            end

            def correct_location?
              requestable.held_at_marquand_library? || requestable.item_at_clancy?
            end

            def user_eligible?
              user.cas_provider? || user.alma_provider?
            end

            attr_reader :requestable, :user
    end
  end
end
