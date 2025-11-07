# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # resource can be requested via Aeon
    class Aeon
      def initialize(requestable:, patron:)
        @requestable = requestable
        @patron = patron
      end

      def to_s
        'aeon'
      end

      def eligible?
        return false unless patron_group_eligible? || patron.guest?
        (requestable.aeon? || !(requestable.alma_managed? || requestable.partner_holding?))
      end

      def patron_group_eligible?
        allowed_patron_groups.include?(patron.patron_group)
      end

      def allowed_patron_groups
        @allowed_patron_groups ||= %w[P REG GRAD SENR UGRD SUM]
      end

    private

      attr_reader :requestable, :patron
    end
  end
end
