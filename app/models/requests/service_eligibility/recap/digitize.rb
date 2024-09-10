# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # recap_edd - material is stored in a recap location that permits digitization
      class Digitize
        def initialize(requestable:, user:)
          @requestable = requestable
          @user = user
        end

        def eligible?
          requestable_eligible? && user_eligible?
        end

        def to_s
          'recap_edd'
        end

        private

          def requestable_eligible?
            return false unless requestable.recap?

            !requestable.recap_pf? &&
              requestable.recap_edd? &&
              requestable.item_data? &&
              !requestable.scsb_in_library_use?
          end

          def user_eligible?
            user.cas_provider? || user.alma_provider?
          end

          attr_reader :requestable, :user
      end
    end
  end
end
