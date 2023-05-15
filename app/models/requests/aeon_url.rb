# frozen_string_literal: true
module Requests
  # Create a URL that creates an aeon request
  class AeonUrl
    # @param document [SolrDocument]
    # @param holding [Hash]
    # @param item [Requests::Requestable::Item]
    def initialize(document:, holding: nil, item: nil)
      @document = document
      @holding = holding.values.first if holding
      @item = item if item
    end

    def to_s
      @compiled_string ||= "#{Requests::Config[:aeon_base]}/OpenURL?#{query_string}"
    end

    private

      def query_string
        "#{ctx_with_item_info.kev}&#{aeon_basic_params.to_query}"
      end

      def ctx_with_item_info
        ctx = @document.to_ctx
        if item.present?
          ctx.referent.set_metadata('iteminfo5', item['id']&.to_s)
          if enum_value.present?
            ctx.referent.set_metadata('volume', enum_value)
            ctx.referent.set_metadata('issue', item[:chron_display]) if item[:chron_display].present?
          else
            ctx.referent.set_metadata('volume', holding['location_has']&.first)
            ctx.referent.set_metadata('issue', nil)
          end
        end
        ctx
      end

      def aeon_basic_params
        {
          ReferenceNumber: @document[:id],
          CallNumber: holding['call_number'],
          Site: site,
          Location: shelf_location_code,
          SubLocation: location_note,
          ItemInfo1: I18n.t("requests.aeon.access_statement"),
          ItemNumber: item&.fetch('barcode', nil)
        }.compact
      end

      def holding
        @holding ||= @document.holdings_all_display.values.first
      end

      def enum_value
        [item['enum_display'], item['enumeration']].join(" ").strip
      end

      def item
        @item ||= holding&.fetch('items', nil)&.first
      end

      def at_mudd?
        location = ::Bibdata.holding_locations.fetch(shelf_location_code, nil)
        location&.fetch('library', nil)&.fetch('code', nil) == 'mudd' || thesis?
      end

      def shelf_location_code
        holding&.fetch('location_code', nil)
      end

      def location_note
        holding[:location_note]&.first
      end

      def thesis?
        @document.holdings_all_display&.keys&.first == "thesis"
      end

      def site
        return 'MUDD' if at_mudd?
        'RBSC'
      end
  end
end
