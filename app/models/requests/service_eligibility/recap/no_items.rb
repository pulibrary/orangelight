# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # recap_no_items - material in a recap location with no item record data
      class NoItems < AbstractRecap
        def eligible?
          requestable_eligible? && user_eligible?
        end

        def to_s
          'recap_no_items'
        end

        private

          def requestable_eligible?
            return false unless requestable.recap?

            !requestable.item_data?
          end
      end
    end
  end
end
