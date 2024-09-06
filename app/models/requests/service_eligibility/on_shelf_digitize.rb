# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request digitization services for a resource
    # that is on the shelf
    class OnShelfDigitize < AbstractOnShelf
      def to_s
        'on_shelf_edd'
      end

        private

          def requestable_eligible?
            on_shelf_eligible?
          end
    end
  end
end
