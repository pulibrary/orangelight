# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # Abstract class for other recap classes to inherit from
      class AbstractRecap
        def initialize(requestable:, user:)
          @requestable = requestable
          @user = user
        end

        def to_s
          raise "Please implement to_s in the subclass"
        end

        protected

          def requestable_eligible?
            raise "Please implement requestable_eligible? in the subclass"
          end

          def user_eligible?
            user.cas_provider? || user.alma_provider?
          end

          attr_reader :requestable, :user
      end
    end
  end
end
