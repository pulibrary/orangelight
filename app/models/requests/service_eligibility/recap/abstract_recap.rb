# frozen_string_literal: true
module Requests
  module ServiceEligibility
    module Recap
      # Abstract class for other recap classes to inherit from
      class AbstractRecap
        def initialize(requestable:, patron:)
          @requestable = requestable
          @patron = patron
        end

        def to_s
          raise "Please implement to_s in the subclass"
        end

        protected

          def requestable_eligible?
            raise "Please implement requestable_eligible? in the subclass"
          end

          def user_eligible?
            patron.core_patron_group? || patron.affiliate_patron_group?
          end

          attr_reader :requestable, :patron
      end
    end
  end
end
