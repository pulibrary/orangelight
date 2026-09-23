# frozen_string_literal: true
module Requests
  module ServiceEligibility
    # This class is responsible for determining if a specific
    # user can request a specific physical resource that is
    # on the shelf
    class OnShelfNoItems < AbstractOnShelf
      def to_s
        'on_shelf_no_items'
      end

        private

          def requestable_eligible?
            return false unless on_shelf_eligible? && requestable.circulates? && !requestable.annex?
            !requestable.item_data?
          end
    end
  end
end
