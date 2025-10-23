# frozen_string_literal: true
module Requests
  class RequestablesList
    # This factory is responsible for creating an array of Requestables for partner items at ReCAP.
    class ScsbItemsFactory
      def initialize(document:, holdings:, location:, patron:)
        @document = document
        @holdings = holdings
        @location = location
        @patron = patron
      end

      def call
        requestable_items = []
        holdings.each do |id, values|
          requestable_items.concat build_holding_scsb_items(id:, values:)
        end
        requestable_items
      end

          private

            attr_reader :document, :holdings, :location, :patron

            # Catalog records that we have indexed from SCSB will have a SCSB internal id (for example: .b22165219x)
            # Alma records do not have this
            def scsb_internal_id
              document['other_id_s'].first
            end

            def scsb_location
              document['location_code_s'].first
            end

            # :reek:DuplicateMethodCall -- it makes it clearer that values['items'] is being mutated to my eye
            def build_holding_scsb_items(id:, values:)
              values['items'] = recap_barcodes.items_with_availability(items: values['items'])
              return [] if values['items'].blank?
              values['items'].map do |item|
                item['location_code'] = location_code
                Requests::Requestable.new(
                  bib: document,
                  holding: Holding.new(mfhd_id: id.to_sym.to_s, holding_data: holdings[id]),
                  item: Item.new(item.with_indifferent_access),
                  location: requestable_location,
                  patron:
                )
              end
            end

            def requestable_location
              location_object = Location.new location
              location["delivery_locations"] = location_object.build_delivery_locations if location_object.delivery_locations.present?
              location
            end

            def location_code
              location['code'] if location
            end

            def recap_barcodes
              @recap_barcodes ||= RecapItemAvailability.new(id: scsb_internal_id, scsb_location:)
            end
    end
  end
end
