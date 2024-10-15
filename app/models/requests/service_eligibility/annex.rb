# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request an item from the annex
    class Annex < AbstractOnShelf
      def to_s
        'annex'
      end

        private

          def requestable_eligible?
            on_shelf_eligible? && requestable.annex?
          end

          def allowed_patron_groups
            @allowed_patron_groups ||= %w[P REG GRAD SENR UGRAD Affiliate-P Affiliate GST]
          end
    end
  end
end
