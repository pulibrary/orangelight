# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # recap - material is stored at recap; can be paged to campus and circulates
      class Pickup < AbstractRecap
        def eligible?
          requestable_eligible? && user_eligible? && patron_eligible?
        end

        def to_s
          'recap'
        end

        private

          def requestable_eligible?
            return false unless requestable.recap?
            requestable.item_data? &&
              !requestable.recap_pf? &&
              !requestable.holding_library_in_library_only? &&
              requestable.circulates? &&
              !(requestable.scsb_in_library_use? && requestable.item[:collection_code] != "MR") &&
              !requestable.charged?
          end

          def patron_eligible?
            requestable.eligible_for_library_services?
          end
      end
    end
  end
end
