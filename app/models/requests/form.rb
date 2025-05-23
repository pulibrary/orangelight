# frozen_string_literal: true
require 'faraday'

module Requests
  # Request class is responsible of building a request
  # using items and location of the holding
  class Form
    attr_reader :system_id
    attr_reader :mfhd
    attr_reader :patron
    attr_reader :doc
    attr_reader :requestable
    attr_reader :requestable_unrouted
    attr_reader :holdings
    attr_reader :location
    attr_reader :location_code
    attr_reader :items
    attr_reader :pick_ups
    alias default_pick_ups pick_ups
    delegate :ctx, to: :@ctx_obj
    delegate :eligible_for_library_services?, to: :patron

    include Requests::Bibdata
    include Requests::Scsb

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd alma holding id
    # @option opts [Patron] :patron current Patron object
    def initialize(system_id:, mfhd:, patron: nil)
      @system_id = system_id
      @doc = SolrDocument.new(solr_doc(system_id))
      @holdings = JSON.parse(doc[:holdings_1display] || '{}')
      # scsb items are the only ones that come in without a MFHD parameter from the catalog now
      # set it for them, because they only ever have one location
      @mfhd = mfhd || @holdings.keys.first
      @patron = patron
      @location_code = @holdings[@mfhd]["location_code"] if @holdings[@mfhd].present?
      @location = load_bibdata_location
      @items = load_items
      @pick_ups = build_pick_ups
      @requestable_unrouted = build_requestable
      @requestable = route_requests(@requestable_unrouted)
      @ctx_obj = Requests::SolrOpenUrlContext.new(solr_doc: doc)
    end

    delegate :user, to: :patron

    def requestable?
      requestable.size.positive?
    end

    def first_filtered_requestable
      requestable&.first
    end

    # Does this request object have any available copies?
    def any_loanable_copies?
      requestable_unrouted.any? do |requestable|
        !(requestable.charged? || (requestable.aeon? || !requestable.circulates? || requestable.partner_holding? || requestable.on_reserve?))
      end
    end

    def any_enumerated?
      requestable_unrouted.any?(&:enumerated?)
    end

    def route_requests(requestable_items)
      routed_requests = []
      return [] if requestable_items.blank?
      requestable_items.each do |requestable|
        router = Requests::Router.new(requestable:, any_loanable: any_loanable_copies?, patron:)
        routed_requests << router.routed_request
      end
      routed_requests
    end

    def serial?
      doc[:format].present? && doc[:format].include?('Journal')
    end

    def recap?
      return false if location.blank?
      location[:remote_storage] == "recap_rmt"
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      return nil if too_many_items?
      mfhd_items = load_items_by_mfhd
      mfhd_items.empty? ? nil : mfhd_items.with_indifferent_access
    end

    # returns basic metadata for hidden fields on the request form via solr_doc values
    # Fields to return all keys are arrays
    ## Add more fields here as needed
    def hidden_field_metadata
      {
        title: doc["title_citation_display"],
        author: doc["author_citation_display"],
        isbn: doc["isbn_s"]&.values_at(0),
        date: doc["pub_date_display"]
      }
    end

    # Calls Requests::BibdataService to get the delivery_locations

    def ill_eligible?
      requestable.any? { |r| r.services.include? 'ill' }
    end

    def other_id
      doc['other_id_s'].first
    end

    def scsb_location
      doc['location_code_s'].first
    end

    # holdings: The holdings1_display from the SolrDocument
    # holding: The holding of the holding_id(mfhd) from the SolrDocument
    # happens on 'click' the 'Request' button
    def too_many_items?
      holding = holdings[@mfhd]
      items = holding.try(:[], "items")
      return false if items.blank?

      return true if items.count > 500

      false
    end

    private

      ### builds a list of possible requestable items
      # returns a collection of requestable objects or nil
      # @return [Array<Requests::Requestable>] array containing Requests::Requestables
      def build_requestable
        return [] if doc._source.blank?
        if doc.scsb_record?
          build_scsb_requestable
        elsif items.present?
          # for single aeon item, ends up in this statement
          build_requestable_with_items
        else
          # for too many aeon items, ends up in this statement
          build_requestable_from_data
        end
      end

      def availability_data(id)
        @availability_data ||= items_by_id(id, scsb_owning_institution(scsb_location))
      end

      # @return [Array<Requests::Requestable>] array containing Requests::Requestables
      def build_scsb_requestable
        requestable_items = []
        holdings.each do |id, values|
          requestable_items = build_holding_scsb_items(id:, values:, availability_data: availability_data(other_id), requestable_items:)
        end
        requestable_items
      end

      # @return [Array<Requests::Requestable>] array containing Requests::Requestables
      def build_holding_scsb_items(id:, values:, availability_data:, requestable_items:)
        values_items = values['items']
        return requestable_items if values_items.blank?
        barcodesort = build_barcode_sort(items: values_items, availability_data:)
        barcodesort.each_value do |item|
          item['location_code'] = location_code
          params = build_requestable_params(item: item.with_indifferent_access, holding: Holding.new(mfhd_id: id.to_sym.to_s, holding_data: holdings[id]),
                                            location:)
          requestable_items << Requests::Requestable.new(**params)
        end
        requestable_items
      end

      def build_barcode_sort(items:, availability_data:)
        barcodesort = {}
        items.each do |item|
          item[:status_label] = status_label(item:, availability_data:)
          barcodesort[item['barcode']] = item
        end
        availability_data.each do |item|
          barcode_item = barcodesort[item['itemBarcode']]
          next if barcode_item.blank? || barcode_item["status_source"] == "work_order" || item['errorMessage'].present?
          barcode_item['status_label'] = item['itemAvailabilityStatus']
          barcode_item['status'] = nil
        end
        barcodesort
      end

      # :reek:DuplicateMethodCall
      def status_label(item:, availability_data:)
        item_object = Item.new item
        if item_object.not_a_work_order? && availability_data.empty?
          "Unavailable"
        elsif item_object.not_a_work_order? && item_object.status_label == 'Item in place' && availability_data.size == 1 && availability_data.first['errorMessage'] == "Bib Id doesn't exist in SCSB database."
          "In Process"
        else
          item_object.status_label
        end
      end

      # @return [Array<Requests::Requestable>] array containing Requests::Requestables
      def build_requestable_with_items
        requestable_items = []
        barcodesort = {}
        barcodesort = build_barcode_sort(items: items[mfhd], availability_data: availability_data(system_id)) if recap?
        # items from the availability lookup using the Bibdata Service
        items.each do |holding_id, mfhd_items|
          next if mfhd != holding_id
          requestable_items = build_requestable_from_mfhd_items(requestable_items:, holding_id:, mfhd_items:, barcodesort:)
        end
        requestable_items.compact
      end

      # @return [Array<Requests::Requestable>] array containing Requests::Requestables or empty array
      def build_requestable_from_data
        return if doc[:holdings_1display].blank?
        return [] if holdings[@mfhd].blank?

        [build_requestable_from_holding(@mfhd, holdings[@mfhd].with_indifferent_access)]
      end

      def build_requestable_from_mfhd_items(requestable_items:, holding_id:, mfhd_items:, barcodesort:)
        if !mfhd_items.empty?
          mfhd_items.each do |item|
            requestable_items << build_requestable_mfhd_item(holding_id, item, barcodesort)
          end
        else
          requestable_items << build_requestable_from_holding(holding_id, holdings[holding_id])
        end
        requestable_items.compact
      end

      def holding_data(item, holding_id, item_location_code)
        if item["in_temp_library"] && item["temp_location_code"] != "RES_SHARE$IN_RS_REQ"
          holdings[item_location_code]
        else
          holdings[holding_id]
        end
      end

      # Item we get from the 'load_items' live call to bibdata
      def build_requestable_mfhd_item(holding_id, item, barcodesort)
        return if item['on_reserve'] == 'Y'
        item['status_label'] = barcodesort[item['barcode']][:status_label] unless barcodesort.empty?
        item_current_location = item_current_location(item)
        params = build_requestable_params(
          item: item.with_indifferent_access,
          holding: Holding.new(mfhd_id: holding_id.to_sym.to_s, holding_data: holding_data(item, holding_id, item_location_code)),
          location: item_current_location
        )
        Requests::Requestable.new(**params)
      end

      def get_current_location(item_location_code:)
        if item_location_code != location_code
          @temp_locations ||= TempLocationCache.new
          @temp_locations.retrieve(item_location_code)
        else
          location
        end
      end

      # This method will always return a Requestable object where .item is a NullItem, because we don't pass an item in
      def build_requestable_from_holding(holding_id, holding)
        return if holding.blank?
        params = build_requestable_params(holding: Holding.new(mfhd_id: holding_id.to_sym.to_s, holding_data: holding), location:)
        Requests::Requestable.new(**params)
      end

      def load_bibdata_location
        return if location_code.blank?
        location = get_location_data(location_code)
        location_object = Location.new location
        location[:delivery_locations] = location_object.sort_pick_ups if location_object.delivery_locations.present?
        location
      end

      def build_requestable_params(params)
        {
          bib: doc,
          holding: params[:holding],
          item: params[:item],
          location: build_requestable_location(params),
          patron:
        }
      end

      def build_requestable_location(params)
        location = params[:location]
        location_object = Location.new location
        location["delivery_locations"] = location_object.build_delivery_locations if location_object.delivery_locations.present?
        location
      end

      ## Loads item availability through the Request Bibdata service using the items_by_mfhd method
      # items_by_mfhd makes the availabiliy call:
      # bibdata_conn.get "/bibliographic/#{system_id}/holdings/#{mfhd_id}/availability.json"
      # rename to: load_items_by_holding_id
      def load_items_by_mfhd
        mfhd_items = {}
        mfhd_items[@mfhd] = items_by_mfhd(@system_id, @mfhd)
        mfhd_items
      end

      def items_to_symbols(items = [])
        items_with_symbols = []
        items.each do |item|
          items_with_symbols << item.with_indifferent_access
        end
        items_with_symbols
      end

      def item_current_location(item)
        @item_location_code = if item['in_temp_library']
                                item['temp_location_code']
                              else
                                item['location']
                              end
        get_current_location(item_location_code:)
      end
      attr_reader :item_location_code
  end
end
