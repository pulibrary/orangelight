# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up a resource that is currently in a non-standard location
    class NonStandardCircLocationPickUpLocations
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        if delivery_location_label.present?
          [{ label: delivery_location_label, gfa_pickup: delivery_location_code, pick_up_location_code: pick_up_location_code, staff_only: false }]
        else
          [{ label: location.library_label, gfa_pickup:, staff_only: false }]
        end
      end

        private

          attr_reader :form, :requestable

          delegate :delivery_location_code, :delivery_location_label, :location, :pick_up_location_code, to: :requestable

          def gfa_pickup
            if library_code == "firestone"
              "PA"
            else
              lib = Requests::BibdataService.delivery_locations.select { |_key, hash| hash["library"]["code"] == library_code }
              lib.keys.first.to_s
            end
          end

          def library_code
            location&.library_code
          end
    end
  end
end
