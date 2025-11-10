# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Annex
      # annex_no_items - annex holding with no item record data
      class NoItems < AbstractAnnex
        def eligible?
          requestable_eligible? && patron_eligible?
        end

        def to_s
          'annex_no_items'
        end

        private

          def requestable_eligible?
            return false unless requestable.annex?
            !requestable.item_data?
          end
      end
    end
  end
end
