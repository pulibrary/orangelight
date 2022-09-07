# frozen_string_literal: true
require 'borrow_direct'
require 'faraday'

module Requests
  class Request
    attr_accessor :email
    attr_accessor :user_name
    attr_reader :system_id
    attr_reader :source
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
    delegate :ctx, :openurl_ctx_kev, to: :@ctx_obj
    delegate :eligible_for_library_services?, to: :patron

    include Requests::Bibdata
    include Requests::Scsb

    # @option opts [String] :system_id A bib record id or a special collection ID value
    # @option opts [Fixnum] :mfhd alma holding id
    # @option opts [Patron] :patron current Patron object
    # @option opts [String] :source represents system that directed user to request form. i.e.
    def initialize(system_id:, mfhd:, patron: nil, source: nil)
      @system_id = system_id
      @doc = solr_doc(system_id)
      @holdings = JSON.parse(doc[:holdings_1display] || '{}')
      # scsb items are the only ones that come in without a MFHD parameter from the catalog now
      # set it for them, because they only ever have one location
      @mfhd = mfhd || @holdings.keys.first
      @patron = patron
      @source = source
      ### These should be re-factored
      @location_code = @holdings[@mfhd]["location_code"] if @holdings[@mfhd].present?
      @location = load_location
      @items = load_items
      @pick_ups = build_pick_ups
      @requestable_unrouted = build_requestable
      @requestable = route_requests(@requestable_unrouted)
      @ctx_obj = Requests::SolrOpenUrlContext.new(solr_doc: @doc)
    end

    delegate :user, to: :patron

    # Is this a partner system id
    def partner_system_id?
      return true if /^SCSB-\d+/.match?(system_id.to_s)
    end

    def requestable?
      requestable.size.positive?
    end

    def single_aeon_requestable?
      requestable.size == 1 && first_filtered_requestable&.services&.include?('aeon')
    end

    def first_filtered_requestable
      requestable&.first
    end

    # Does this request object have any pageable items?
    def any_pageable?
      services = requestable.map(&:services).flatten
      services.uniq!
      services.include? 'paging'
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
      any_loanable = any_loanable_copies?
      requestable_items.each do |requestable|
        router = Requests::Router.new(requestable: requestable, user: patron.user, any_loanable: any_loanable)
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

    def all_items_online?
      requestable.map(&:online?).reduce(:&)
    end

    # returns nil if there are no attached items
    # if mfhd set returns only items associated with that mfhd
    # if no mfhd returns items sorted by mfhd
    def load_items
      return nil if thesis? || numismatics?
      mfhd_items = if @mfhd && serial?
                     load_serial_items
                   else
                     # load_items_by_bib_id
                     load_items_by_mfhd
                   end
      mfhd_items.empty? ? nil : mfhd_items.with_indifferent_access
    end

    def thesis?
      doc[:holdings_1display].present? && parse_json(doc[:holdings_1display]).key?('thesis')
    end

    def numismatics?
      doc[:holdings_1display].present? && parse_json(doc[:holdings_1display]).key?('numismatics')
    end

    # returns basic metadata for display on the request from via solr_doc values
    # Fields to return all keys are arrays
    ## Add more fields here as needed
    def display_metadata
      {
        title: doc["title_citation_display"],
        author: doc["author_citation_display"],
        isbn: doc["isbn_s"]
      }
    end

    def language
      doc["language_iana_s"]&.first
    end

    # should probably happen in the initializer
    def build_pick_ups
      pick_up_locations = []
      Requests::BibdataService.delivery_locations.each_value do |pick_up|
        pick_up_locations << { label: pick_up["label"], gfa_pickup: pick_up["gfa_pickup"], pick_up_location_code: pick_up["library"]["code"] || 'firestone', staff_only: pick_up["staff_only"] } if pick_up["pickup_location"] == true
      end
      # pick_up_locations.sort_by! { |loc| loc[:label] }
      sort_pick_ups(pick_up_locations)
    end

    # if a Record is a serial/multivolume no Borrow Direct
    def borrow_direct_eligible?
      if (any_loanable_copies? && any_enumerated?) || patron.guest?
        false
      else
        requestable.any? { |r| r.services.include? 'bd' }
      end
    end

    def ill_eligible?
      requestable.any? { |r| r.services.include? 'ill' }
    end

    def isbn_numbers?
      if doc.key? 'isbn_s'
        true
      else
        false
      end
    end

    def isbn_numbers
      doc['isbn_s']
    end

    def other_id
      doc['other_id_s'].first
    end

    def scsb_location
      doc['location_code_s'].first
    end

    def off_site?
      return false if location['library'].nil? || location['library']['code'].nil?
      library_code = location[:library][:code]
      library_code == 'recap' || library_code == 'marquand' || library_code == 'annex'
    end

    private

      ### builds a list of possible requestable items
      # returns a collection of requestable objects or nil
      def build_requestable
        return [] if doc.blank?
        if partner_system_id?
          build_scsb_requestable
        elsif !items.nil?
          build_requestable_with_items
        else
          build_requestable_from_data
        end
      end

      def availability_data(id)
        @availability_data ||= begin
          items_by_id(id, scsb_owning_institution(scsb_location))
        end
      end

      def build_scsb_requestable
        requestable_items = []
        ## scsb processing
        ## If mfhd present look for only that
        ## sort items by keys
        ## send query for availability by barcode
        ## overlay availability to the 'status' field
        ## make sure other fields map to the current data model for item in requestable
        ## adjust router to understand SCSB status
        holdings.each do |id, values|
          requestable_items = build_holding_scsb_items(id: id, values: values, availability_data: availability_data(other_id), requestable_items: requestable_items)
        end
        requestable_items
      end

      def build_holding_scsb_items(id:, values:, availability_data:, requestable_items:)
        return requestable_items if values['items'].nil?
        barcodesort = build_barcode_sort(items: values['items'], availability_data: availability_data)
        barcodesort.each_value do |item|
          item['location_code'] = location_code
          params = build_requestable_params(item: item.with_indifferent_access, holding: { id.to_sym.to_s => holdings[id] },
                                            location: location)
          requestable_items << Requests::Requestable.new(params)
        end
        requestable_items
      end

      def build_barcode_sort(items:, availability_data:)
        barcodesort = {}
        items.each do |item|
          item[:status_label] = status_label(item: item, availability_data: availability_data)
          barcodesort[item['barcode']] = item
        end
        availability_data.each do |item|
          barcode_item = barcodesort[item['itemBarcode']]
          next if barcode_item.nil? || barcode_item["status_source"] == "work_order" || item['errorMessage'].present?
          barcode_item['status_label'] = item['itemAvailabilityStatus']
          barcode_item['status'] = nil
        end
        barcodesort
      end

      def status_label(item:, availability_data:)
        if item["status_source"] != "work_order" && availability_data.empty?
          "Not Available"
        elsif item["status_source"] != "work_order" && item[:status_label] == 'Item in place' && availability_data.size == 1 && availability_data.first['errorMessage'] == "Bib Id doesn't exist in SCSB database."
          "In Process"
        elsif item["status_source"] == "work_order" && item["status"] == "Not Available" && item[:status_label] != "Acquisitions and Cataloging"
          "Not Available"
        else
          item[:status_label]
        end
      end

      def build_requestable_with_items
        requestable_items = []
        barcodesort = {}
        barcodesort = build_barcode_sort(items: items[mfhd], availability_data: availability_data(system_id)) if recap?
        items.each do |holding_id, mfhd_items|
          next if mfhd != holding_id
          requestable_items = build_requestable_from_mfhd_items(requestable_items: requestable_items, holding_id: holding_id, mfhd_items: mfhd_items, barcodesort: barcodesort)
        end
        requestable_items.compact
      end

      def build_requestable_from_data
        return if doc[:holdings_1display].nil?
        @mfhd ||= 'thesis' if thesis?
        @mfhd ||= 'numismatics' if numismatics?
        return [] if holdings[@mfhd].blank?

        [build_requestable_from_holding(@mfhd, holdings[@mfhd].with_indifferent_access)]
      end

      def build_requestable_from_mfhd_items(requestable_items:, holding_id:, mfhd_items:, barcodesort:)
        if !mfhd_items.empty?
          mfhd_items.each do |item|
            requestable_items << build_requestable_mfhd_item(requestable_items, holding_id, item, barcodesort)
          end
        else
          requestable_items << build_requestable_from_holding(holding_id, holdings[holding_id])
        end
        requestable_items.compact
      end

      def build_requestable_mfhd_item(_requestable_items, holding_id, item, barcodesort)
        item_loc = item_current_location(item)
        current_location = get_current_location(item_loc: item_loc)
        item['status_label'] = barcodesort[item['barcode']][:status_label] unless barcodesort.empty?
        calculate_holding = if item["in_temp_library"] && item["temp_location_code"] != "RES_SHARE$IN_RS_REQ"
                              { holding_id.to_sym.to_s => holdings[item_loc] }
                            else
                              { holding_id.to_sym.to_s => holdings[holding_id] }
                            end
        params = build_requestable_params(
          item: item.with_indifferent_access,
          holding: calculate_holding,
          location: current_location
        )
        # sometimes availability returns items without any status
        # see https://github.com/pulibrary/marc_liberation/issues/174
        Requests::Requestable.new(params) # unless item["status"].nil?
      end

      def get_current_location(item_loc:)
        if item_loc != location_code
          @temp_locations ||= {}
          @temp_locations[item_loc] = get_location_data(item_loc) if @temp_locations[item_loc].blank?
          @temp_locations[item_loc]
        else
          location
        end
      end

      def build_requestable_from_holding(holding_id, holding)
        return if holding.blank?
        params = build_requestable_params(holding: { holding_id.to_sym.to_s => holding }, location: location)
        Requests::Requestable.new(params)
      end

      def load_location
        return if location_code.nil?
        location = get_location_data(location_code)
        location[:delivery_locations] = sort_pick_ups(location[:delivery_locations]) if location[:delivery_locations]&.present?
        location
      end

      def build_requestable_params(params)
        {
          bib: doc.with_indifferent_access,
          holding: params[:holding],
          item: params[:item],
          location: build_requestable_location(params),
          patron: patron
        }
      end

      def build_requestable_location(params)
        location = params[:location]
        location["delivery_locations"] = build_delivery_locations(location["delivery_locations"]) if location["delivery_locations"].present?
        location
      end

      def build_delivery_locations(delivery_locations)
        delivery_locations.map do |loc|
          pick_up_code = loc["library"]["code"] if loc["library"].present?
          pick_up_code ||= 'firestone'
          loc.merge("pick_up_location_code" => pick_up_code) { |_key, v1, _v2| v1 }
        end
      end

      # Not sure why this method exists
      def load_serial_items
        mfhd_items = {}
        items_as_json = items_by_mfhd(@system_id, @mfhd)
        unless items_as_json.empty?
          items_with_symbols = items_to_symbols(items_as_json)
          mfhd_items[@mfhd] = items_with_symbols
        end
        # else
        #   empty_mfhd = items_by_bib(@system_id)
        #   mfhd_items[@mfhd] = [empty_mfhd[@mfhd]]
        # end
        mfhd_items
      end

      ## this method should be the only place we load item availability
      def load_items_by_mfhd
        mfhd_items = {}
        mfhd_items[@mfhd] = items_by_mfhd(@system_id, @mfhd)
        # items_by_mfhd(@system_id, @mfhd).each do |item_info|
        #  mfhd_items[item_info['id']] = load_item_for_holding(holding_id: @mfhd, item_info: item_info)
        # end
        mfhd_items
      end

      # def load_items_by_bib_id
      #   mfhd_items = {}
      #   items_by_bib(@system_id).each do |holding_id, item_info|
      #     next if @mfhd != holding_id
      #     mfhd_items[holding_id] = load_item_for_holding(holding_id: holding_id, item_info: item_info)
      #   end
      #   mfhd_items
      # end

      # def load_item_for_holding(holding_id:, item_info:)
      #   # new check needed here
      #   if item_info[:more_items] == false
      #     if item_info[:status].starts_with?('On-Order') || item_info[:status].starts_with?('Pending Order')
      #       [item_info]
      #     elsif item_info[:status].starts_with?('Online')
      #       [item_info]
      #     else
      #       ## we don't need to call this again
      #       items_to_symbols(items_by_mfhd(@system_id, holding_id))
      #     end
      #   else
      #     ## we don't need to call this again
      #     # items_to_symbols(items_by_mfhd(@system_id, holding_id))
      #     items_to_symbols([item_info])
      #   end
      # end

      def items_to_symbols(items = [])
        items_with_symbols = []
        items.each do |item|
          items_with_symbols << item.with_indifferent_access
        end
        items_with_symbols
      end

      def item_current_location(item)
        if item['in_temp_library']
          item['temp_location_code']
        else
          item['location']
        end
      end
  end
end
