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
      delegate :location, to: :requestable

      def all_delivery_locations
        if delivery_locations&.any?
          delivery_locations
        else
          default_pick_ups
        end
      end

      # :reek:UtilityFunction
      def valid_annex_pickup?(location_hash)
        # This excludes PQ (Plasma) and PH (Mudd), which are not valid but are currently listed as pickup locations
        # in bibdata holding_locations.json
        ['PA', 'PB', 'PF', 'PJ', 'PK', 'PL', 'PM', 'PT', 'PW', 'QA', 'QC', 'QL', 'QP', 'QT', 'QX'].include?(location_hash[:gfa_pickup])
      end

      def delivery_locations
        location[:delivery_locations]
      end
    end
  end
end
