# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # on_order - material has a status in Alma that indicates it is ordered but has not yet arrived on campus
    class OnOrder
      def initialize(requestable:, user:)
        @requestable = requestable
        @user = user
      end

      def to_s
        'on_order'
      end

      def eligible?
        requestable_eligible? && user_eligible?
      end

      private

        def requestable_eligible?
          requestable.on_order? && !requestable.charged? && !requestable.in_process?
        end

        def user_eligible?
          user.cas_provider? || user.alma_provider?
        end

        attr_reader :requestable, :user
    end
  end
end
