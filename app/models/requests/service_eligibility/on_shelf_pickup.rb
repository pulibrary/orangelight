# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request a specific physical resource that is
    # on the shelf
    class OnShelfPickup < AbstractOnShelf
      def to_s
        'on_shelf'
      end

        private

          def requestable_eligible?
            on_shelf_eligible? && requestable.circulates? && !requestable.annex?
          end
    end
  end
end
