# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up a resource from the Annex
    class AnnexPickUpLocations
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        pick_ups = all_delivery_locations.select { |loc| valid_annex_pickup?(loc) }
        pick_ups << default_pick_ups[0] if pick_ups.empty?
        pick_ups
      end

    private

      attr_reader :form, :requestable

      delegate :default_pick_ups, to: :form
      delegate :location, :patron, to: :requestable

      def all_delivery_locations
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

      # :reek:UtilityFunction
      def valid_annex_pickup?(location_hash)
        ['PA', 'PK', 'PL', 'PM', 'PT', 'PW', 'QA', 'QC', 'QL', 'QP', 'QT', 'QX'].include?(location_hash[:gfa_pickup])
      end

      def delivery_locations
        location[:delivery_locations]
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
