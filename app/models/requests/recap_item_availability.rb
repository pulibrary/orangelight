# frozen_string_literal: true
module Requests
  # This class is responsible for finding availability data from SCSB for items in ReCAP (whether owned by PUL or a partner)
  class RecapItemAvailability
    include Scsb

    def initialize(id:, scsb_location:)
      @id = id
      @scsb_location = scsb_location
    end

    # Returns an array of item hashes
    def items_with_availability(items:)
      items.map { |item| ItemWithAvailability.new(availability_data:, item:).call }
    end

    # This inner class is responsible for adding availability data that has already been fetch from SCSB to an item hash
    class ItemWithAvailability
      def initialize(availability_data:, item:)
        @availability_data = availability_data
        @item = item
      end

      def call
        # Not sure why we set the string and symbol versions to different values...
        item[:status_label] = status_label
        if availability_for_item && availability_for_item['errorMessage'].blank? && item['status_source'] != 'work_order'
          item['status_label'] = availability_for_item['itemAvailabilityStatus']
          item['status'] = nil
        end
        item
      end

      private

        attr_reader :availability_data, :item

        delegate :not_a_work_order?, to: :item_object

        def availability_for_item
          @availability_for_item ||= availability_data.find { |scsb_item| scsb_item['itemBarcode'] == item['barcode'] }
        end

        def status_label
          if not_a_work_order? && availability_data.empty?
            "Unavailable"
          elsif not_a_work_order? && original_status_label == 'Item in place' && availability_data.size == 1 && availability_data.first['errorMessage'] == "Bib Id doesn't exist in SCSB database."
            "In Process"
          else
            original_status_label
          end
        end

        def item_object
          Item.new item
        end

        def original_status_label
          item_object.status_label
        end
    end

      private

        attr_reader :id, :scsb_location

        def availability_data
          @availability_data ||= items_by_id(id, scsb_owning_institution(scsb_location))
        end
  end
end
