# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # ask_me - catchall service if the item isn't eligible for anything else.
      class AskMe < AbstractRecap
        def eligible?
          requestable_eligible? && user_eligible? && patron_eligible?
        end

        def to_s
          'ask_me'
        end

        private

          def requestable_eligible?
            return false unless requestable.recap?

            requestable.scsb_in_library_use?
          end

          # The patron is eligible for this service
          # if they are *not* eligible for library services in general
          def patron_eligible?
            !requestable.eligible_for_library_services?
          end
      end
    end
  end
end
