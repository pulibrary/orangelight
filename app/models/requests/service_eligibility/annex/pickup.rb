# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Annex
      # annex - item is stored at annex; can be paged to campus and circulates
      class Pickup < AbstractAnnex
        def eligible?
          requestable_eligible? && patron_eligible?
        end

        def to_s
          'annex'
        end

        private

          def requestable_eligible?
            return false unless requestable.annex?
            on_shelf_eligible? && requestable.item_data?
          end

          def on_shelf_eligible?
            !requestable.charged? && !requestable.in_process? && !requestable.on_order?
          end
      end
    end
  end
end
