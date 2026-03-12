# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up an Alma resource
    class AlmaPickUpLocations
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        if delivery_locations&.any?
          delivery_locations
        else
          default_pick_ups
        end
      end

    private

      attr_reader :form, :requestable

      delegate :default_pick_ups, to: :form
      delegate :location, to: :requestable

      def delivery_locations
        location[:delivery_locations]
      end
    end
  end
end
