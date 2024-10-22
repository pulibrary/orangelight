# frozen_string_literal: true
module Requests
  module ServiceEligibility
    class ClancyEdd
      def initialize(requestable:, patron:)
        @requestable = requestable
        @user = patron.user
        @patron = patron
      end

      def to_s
        'clancy_edd'
      end

      def eligible?
        requestable_eligible? && user_eligible? && patron_eligible?
      end

    private

      def user_eligible?
        user.cas_provider? || user.alma_provider?
      end

      def patron_eligible?
        allowed_patron_groups.include?(patron.patron_group)
      end

      def allowed_patron_groups
        @allowed_patron_groups ||= %w[P REG GRAD SENR UGRD]
      end

      def requestable_eligible?
        requestable.item_at_clancy? && requestable.clancy_available? &&
          requestable.held_at_marquand_library? &&
          !(requestable.recap? || requestable.recap_pf?) &&
          !requestable.annex? &&
          !requestable.on_order? &&
          !requestable.in_process? &&
          !requestable.charged? &&
          (requestable.alma_managed? || requestable.partner_holding?) &&
          !requestable.aeon?
      end

      attr_reader :requestable, :user, :patron
    end
  end
end
