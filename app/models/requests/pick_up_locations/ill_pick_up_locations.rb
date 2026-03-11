# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up a resource that Princeton will request on their
    # behalf from another library via ILLiad
    class ILLPickUpLocations
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        firestone = all_delivery_locations.find { |location| location[:gfa_pickup] == "PA" }
        [firestone].compact
      end

      private

        attr_reader :form, :requestable

        delegate :default_pick_ups, to: :form
        delegate :location, to: :requestable

        def all_delivery_locations
          if delivery_locations&.any?
            delivery_locations
          else
            default_pick_ups
          end
        end

        def delivery_locations
          location[:delivery_locations]
        end
    end
  end
end
