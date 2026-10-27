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

        return delivery_locations_with_pppl if eligible_pickup_from_pppl?
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

      def eligible_pickup_from_pppl?
        patron.eligible_pickup_from_pppl?
      end

      def delivery_locations_with_pppl
        if recap_pickup_at_plasma_physics_pa?
          delivery_locations_not_only_staff_with_plasma_pa
        else
          delivery_locations_not_only_staff_with_plasma_pq
        end
      end

      def delivery_locations_not_only_staff_with_plasma_pa
        # we want to make sure that we insert the
        # location with gfa pickup 'PA' that is Plasma Physics not Firestone
        pa_location = default_pick_ups.find { |location| location[:gfa_pickup] == "PA" && location[:label] == "Plasma Physics Library" }
        delivery_locations_not_including_staff_only << pa_location if pa_location
      end

      def delivery_locations_not_only_staff_with_plasma_pq
        pq_location = default_pick_ups.find { |location| location[:gfa_pickup] == "PQ" }
        delivery_locations_not_including_staff_only << pq_location if pq_location
      end

      def recap_location?(location_code)
        location.present? && location.code == "recap$#{location_code}"
      end

      def recap_qv?
        recap_location?("qv")
      end

      def recap_gp?
        recap_location?("gp")
      end

      def recap_pa?
        recap_location?("pa")
      end

      def recap_pickup_at_plasma_physics_pa?
        # pppl users in patron_group P or REG
        # and statistic group PPPL
        # pick up alma items from
        # these recap locations in Plasma with gfa_pickup PA
        recap_qv? || recap_pa? || recap_gp?
      end
    end
  end
end
