# frozen_string_literal: true
module Requests
  class RequestablesList
    # This factory is responsible for creating a Requestable that have no items
    class NoItemsFactory
      def initialize(document:, holding:, location:, patron:)
        @document = document
        @holding = holding
        @location = location
        @patron = patron
      end

      def call
        return [] if document[:holdings_1display].blank?
        return [] if holding.blank?

        [Requests::Requestable.new(
          bib: document,
          holding:,
          item: placeholder_item_class.new({}),
          location: location_with_delivery_locations,
          patron:
        )]
      end

        private

          attr_reader :document, :holding, :location, :patron

          def location_with_delivery_locations
            location_object = Location.new location
            location["delivery_locations"] = location_object.build_delivery_locations if location_object.delivery_locations.present?
            location
          end

          def placeholder_item_class
            NullItem
          end
    end
  end
end
