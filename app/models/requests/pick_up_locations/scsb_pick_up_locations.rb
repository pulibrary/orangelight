# frozen_string_literal: true
module Requests
  module PickUpLocations
    # This class is responsible for providing the delivery locations where
    # a user can pick up a SCSB resource
    class ScsbPickUpLocations
      def initialize(form:, requestable:)
        @form = form
        @requestable = requestable
      end

      def call
        if requestable.recap?
          pick_ups = all_delivery_pickup_locations.select { |loc| Requests::Location.valid_recap_annex_pickup?(loc) }
          pick_ups << default_pick_ups[0] if pick_ups.empty?
          pick_ups
        else
          all_delivery_pickup_locations
        end
      end

      private

        attr_reader :form, :requestable

        delegate :default_pick_ups, to: :form
        delegate :item, :location, to: :requestable

        def all_delivery_pickup_locations
          return default_pick_ups unless delivery_locations&.any?
          if ['AR', 'FL'].include? collection_code
            # FL (Harvard) and AR (Columbia) can only be requested to marquand
            [bibdata_delivery_locations[:PJ]]
          elsif collection_code == 'MR'
            [bibdata_delivery_locations[:PK]]
          else
            delivery_locations
          end
        end

        def collection_code
          @collection_code ||= item[:collection_code]
        end

        def delivery_locations
          location[:delivery_locations]
        end

        def bibdata_delivery_locations
          @bibdata_delivery_locations ||= Requests::BibdataService.delivery_locations
        end
    end
  end
end
