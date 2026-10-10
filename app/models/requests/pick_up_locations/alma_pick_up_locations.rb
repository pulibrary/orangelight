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
        # patron_group: 'lib', has access to offsite locations
        # when a location has delivery locations configured in bibdata
        # we need to filter out the Staff locations that are for the library staff
        return default_pick_ups if delivery_locations.empty?
        return delivery_locations if library_staff_patron_group?
        return delivery_locations_faculty_pppl if eligible_faculty_pickup_pppl?
        delivery_locations_not_including_staff_only
      end

    private

      attr_reader :form, :requestable

      delegate :default_pick_ups, to: :form
      delegate :location, :patron, to: :requestable

      def delivery_locations
        location[:delivery_locations] || []
      end

      def library_staff_patron_group?
        patron.library_staff_patron_group?
      end

      def delivery_locations_not_including_staff_only
        delivery_locations&.reject { |loc| loc["staff_only"] == true }
      end

      def eligible_faculty_pickup_pppl?
        patron.eligible_faculty_pickup_pppl?
      end

      def delivery_locations_faculty_pppl
        delivery_locations_not_including_staff_only.insert(-2, default_pick_ups.find { |location| location[:gfa_pickup] == "PQ" })
      end
    end
  end
end
