# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # resource can be requested via Aeon
    class Aeon
      def initialize(requestable:)
        @requestable = requestable
      end

      def to_s
        'aeon'
      end

      def eligible?
        requestable.aeon? || !(requestable.alma_managed? || requestable.partner_holding?)
      end

    private

      attr_reader :requestable
    end
  end
end
