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
          # patron_group: 'lib', has access to offsite locations
          # when a location has delivery locations configured in bibdata
          # we need to filter out the Staff locations that are for the library staff
          if library_staff_patron_group?
            delivery_locations
          else
            delivery_locations_not_including_staff_only
          end
        else
          default_pick_ups
        end
      end

    private

      attr_reader :form, :requestable

      delegate :default_pick_ups, to: :form
      delegate :location, :patron, to: :requestable

      def delivery_locations
        location[:delivery_locations]
      end

      def recap?
        location[:remote_storage] == "recap_rmt"
      end

      def library_staff_patron_group?
        patron.library_staff_patron_group?
      end

      def delivery_locations_not_including_staff_only
        delivery_locations&.reject { |loc| loc["staff_only"] == true }
      end
    end
  end
end
