# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # recap_in_library - material is stored at recap; can be paged to campus, but does not circulate
      class InLibrary < AbstractRecap
        def eligible?
          requestable_eligible? && user_eligible?
        end

        def to_s
          'recap_in_library'
        end

        private

          def requestable_eligible?
            return false unless requestable.recap?

            (requestable.scsb_in_library_use? && requestable.item[:collection_code] != "MR") ||
              (!requestable.circulates? && !requestable.recap_edd?) ||
              requestable.recap_pf?
          end
      end
    end
  end
end
