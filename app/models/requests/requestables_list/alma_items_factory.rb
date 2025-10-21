# frozen_string_literal: true
module Requests
  class RequestablesList
    # This factory is responsible for creating an array of Requestables for items from Alma
    # (which will have a MFHD).  This includes Princeton-owned titles that are at ReCAP.
    class AlmaItemsFactory
      include Bibdata
      # :reek:LongParameterList
      # rubocop:disable Metrics/ParameterLists
      def initialize(document:, holdings:, items:, location:, mfhd:, patron:)
        @document = document
        @holdings = holdings
        @items = items
        @location = location
        @mfhd = mfhd
        @patron = patron
      end

      # rubocop:enable Metrics/ParameterLists

      def call
        add_scsb_availability_data_to_items
        items.reduce([]) do |requestables, (holding_id, mfhd_items)|
          requestables.concat requestable_mfhd_items(mfhd_items:) if mfhd == holding_id
        end
      end

        private

          attr_accessor :items

          def add_scsb_availability_data_to_items
            items[mfhd] = RecapItemAvailability.new(id: system_id, scsb_location:).items_with_availability(items: items[mfhd]) if recap?
          end

          def location_code
            location['code'] if location
          end

          def scsb_location
            document['location_code_s'].first
          end

          def requestable_mfhd_items(mfhd_items:)
            if mfhd_items.empty?
              NoItemsFactory.new(document:, holding:, location:, patron:).call
            else
              mfhd_items.map { |item| requestable_mfhd_item(item) }
            end.compact
          end

          def requestable_mfhd_item(item)
            return if item['on_reserve'] == 'Y'
            item_current_location = item_current_location(item)

            Requests::Requestable.new(
              bib: document,
              holding: holding_data(item, item_current_location['code']),
              item: Item.new(item.with_indifferent_access),
              location: item_current_location,
              patron:
            )
          end

          def holding_data(item, item_location_code)
            holding_data = if item["in_temp_library"] && item["temp_location_code"] != "RES_SHARE$IN_RS_REQ"
                             holdings[item_location_code]
                           else
                             holdings[mfhd]
                           end
            Holding.new(mfhd_id: mfhd.to_sym.to_s, holding_data:)
          end

          # Calls Requests::BibdataService to get the delivery_locations
          # :reek:TooManyStatements
          def item_current_location(item)
            item_location_code = if item['in_temp_library']
                                   item['temp_location_code']
                                 else
                                   item['location']
                                 end
            current_location = if item_location_code == location_code
                                 location
                               else
                                 temp_locations.retrieve(item_location_code)
                               end
            current_location_object = Location.new current_location
            current_location["delivery_locations"] = current_location_object.build_delivery_locations if current_location_object.delivery_locations.present?
            current_location
          end

          attr_reader :document, :holdings, :location, :mfhd, :patron

          # Is this Princeton title at recap?
          def recap?
            return false if location.blank?
            location[:remote_storage] == "recap_rmt"
          end

          def system_id
            document.id
          end

          def holding
            Holding.new(mfhd_id: mfhd, holding_data: holdings[mfhd])
          end

          def temp_locations
            @temp_locations ||= TempLocationCache.new
          end
    end
  end
end
