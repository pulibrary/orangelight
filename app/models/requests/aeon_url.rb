# frozen_string_literal: true
module Requests
  # Create a URL that creates an aeon request
  class AeonUrl
    # @param document [SolrDocument]
    # @param holding [Hash]
    # @param item [Requests::Item]
    def initialize(document:, holding: nil, item: nil)
      @document = document
      @holding = holding.values.first if holding
      @item = item if item
    end

    def to_s
      aeon_url = Requests.config[:aeon_base]
      aeon_connector = "?Action=10&Form=30&"
      @compiled_string ||= "#{aeon_url}#{aeon_connector}#{query_string}"
    end

    private

      attr_reader :document

      def query_string
        "#{ctx_with_item_info.kev}&#{aeon_basic_params.to_query}"
      end

      def ctx_with_item_info
        ctx = @document.to_ctx
        if item.present?
          ctx.referent.set_metadata('iteminfo5', item['id']&.to_s)
          if item.enum_value.present?
            ctx.referent.set_metadata('volume', item.enum_value)
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
          SubLocation: sub_location,
          ItemInfo1: I18n.t("requests.aeon.access_statement"),
          ItemNumber: item&.barcode,
          'rft.aucorp': document['pub_citation_display']&.first
        }.compact
      end

      def holding
        @holding ||= @document.holdings_all_display.values.first
      end

      def item
        @item ||= item_from_holding || item_from_document || Item.new({})
      end

      def item_from_holding
        item_hash = holding&.fetch('items', nil)&.first
        Item.new(item_hash.with_indifferent_access) if item_hash
      end

      def item_from_document
        item_hash = @document.holdings_all_display.values.first&.fetch('items', nil)&.first
        Item.new(item_hash.with_indifferent_access) if item_hash
      end

      def at_marquand?
        holding_location&.dig('library', 'code') == 'marquand'
      end

      def at_mudd?
        holding_location&.dig('library', 'code') == 'mudd' || thesis?
      end

      def holding_location
        ::Bibdata.holding_locations.fetch(shelf_location_code, nil)
      end

      def shelf_location_code
        holding&.fetch('location_code', nil)
      end

      def sub_location
        holding&.fetch('sub_location', nil)&.first
      end

      def thesis?
        @document.holdings_all_display&.keys&.first == "thesis"
      end

      def site
        return 'MUDD' if at_mudd?
        return 'MARQ' if at_marquand?
        'FIRE'
      end
  end
end
