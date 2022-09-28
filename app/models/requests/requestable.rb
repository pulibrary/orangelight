# frozen_string_literal: true
module Requests
  class Requestable
    attr_reader :bib
    attr_reader :holding
    attr_reader :item
    attr_reader :location
    attr_reader :call_number
    attr_reader :title
    attr_reader :user_barcode
    attr_reader :patron
    attr_accessor :services

    delegate :pageable_loc?, to: :@pageable
    delegate :map_url, to: :@mappable
    delegate :illiad_request_url, :illiad_request_parameters, to: :@illiad
    delegate :eligible_for_library_services?, to: :@patron

    include Requests::Aeon

    # @param bib [Hash] Solr Document of the Top level Request
    # @param holding [Hash] Bib Data information on where the item is held (Marc liberation) parsed solr_document[holdings_1display] json
    # @param item [Hash] Item level data from bib data (https://bibdata.princeton.edu/availability?id= or mfhd=)
    # @param location [Hash] The has for a bib data holding (https://bibdata.princeton.edu/locations/holding_locations)
    # @param patron [Patron] the patron information about the current user
    def initialize(bib:, holding: nil, item: nil, location: nil, patron:)
      @bib = bib
      @holding = holding
      @item = item.present? ? Item.new(item) : Item::NullItem.new
      @location = location
      @services = []
      @patron = patron
      @user_barcode = patron.barcode
      @call_number = holding.first[1]&.dig 'call_number_browse'
      @title = bib[:title_citation_display]&.first
      @pageable = Pageable.new(call_number: call_number, location_code: location_code)
      @mappable = Requests::Mapable.new(bib_id: bib[:id], holdings: holding, location_code: location_code)
      @illiad = Requests::Illiad.new(enum: item&.fetch(:enum, nil), chron: item&.fetch(:chron, nil), call_number: holding.first[1]&.dig('call_number_browse'))
    end

    delegate :pick_up_location_id, :pick_up_location_code, :item_type, :enum_value, :cron_value, :item_data?,
             :temp_loc?, :in_resource_sharing?, :on_reserve?, :inaccessible?, :hold_request?, :enumerated?, :item_type_non_circulate?, :partner_holding?,
             :id, :use_statement, :collection_code, :missing?, :charged?, :status, :status_label, :barcode?, :barcode, to: :item

    # non alma options
    def thesis?
      holding.key?("thesis") && holding["thesis"][:location_code] == 'mudd$stacks'
    end

    def numismatics?
      holding.key?("numismatics") && holding["numismatics"][:location_code] == 'rare$num'
    end

    # Reading Room Request
    def aeon?
      location[:aeon_location] == true || (use_statement == 'Supervised Use')
    end

    # at an open location users may go to
    def open?
      location[:open] == true
    end

    def recap?
      return false unless location_valid?
      location[:remote_storage] == "recap_rmt"
    end

    def recap_pf?
      return false unless recap?
      location_code == "firestone$pf"
    end

    def clancy?
      return false unless held_at_marquand_library?
      clancy_item.at_clancy? && clancy_item.available?
    end

    def recap_edd?
      return location[:recap_electronic_delivery_location] == true unless partner_holding?
      scsb_edd_collection_codes.include?(collection_code) && !scsb_in_library_use?
    end

    def lewis?
      ['sci', 'scith', 'sciref', 'sciefa', 'sciss'].include?(location_code)
    end

    def plasma?
      location_code == 'ppl'
    end

    def preservation?
      location_code == 'pres'
    end

    def annex?
      location_valid? && location[:library][:code] == 'annex'
    end

    def circulates?
      item_type_non_circulate? == false && location[:circulates] == true && open_libraries.include?(location[:library][:code])
    end

    def can_be_delivered?
      circulates? && !scsb_in_library_use? && !holding_library_in_library_only?
    end

    def always_requestable?
      location[:always_requestable] == true
    end

    def use_restriction?
      partner_holding? && use_statement.present?
    end

    def in_process?
      return false if !item? || partner_holding?
      in_process_statuses.include?(item[:status_label])
    end

    def on_order?
      return false unless item? && !partner_holding?
      item[:status_label] == 'Acquisition'
    end

    def item?
      item.present?
    end

    def traceable?
      services.include?('trace')
    end

    def pending?
      return false unless location_valid?
      return false unless on_order? || in_process? || preservation?
      location[:library][:code] != 'recap' || location[:holding_library].present?
    end

    def ill_eligible?
      services.include?('ill')
    end

    def on_shelf?
      services.include?('on_shelf')
    end

    def borrow_direct?
      services.include?('bd')
    end

    # assume numeric ids come from alma
    def alma_managed?
      bib[:id].to_i.positive?
    end

    def online?
      location_valid? && location[:library][:code] == 'online'
    end

    def urls
      return {} unless online? && bib['electronic_access_1display']
      JSON.parse(bib['electronic_access_1display'])
    end

    def pageable?
      !charged? && pageable_loc?
    end

    def pick_up_locations
      return nil if location[:delivery_locations].empty?
      if partner_holding?
        scsb_pick_up_override(item[:collection_code])
      else
        location[:delivery_locations]
      end
    end

    # override the default delivery location for SCSB at certain collection codes
    def scsb_pick_up_override(collection_code)
      if ['AR', 'FL'].include? collection_code
        [Requests::BibdataService.delivery_locations[:PJ]]
      elsif collection_code == 'MR'
        [Requests::BibdataService.delivery_locations[:PK]]
      else
        location[:delivery_locations]
      end
    end

    def scsb_in_library_use?
      return false unless item?
      partner_holding? && (item[:use_statement] == "In Library Use" || collection_code == 'FL')
    end

    def holding_library_in_library_only?
      return false unless location["holding_library"]
      ["marquand", "lewis"].include?(holding_library) || recap_pf?
    end

    def holding_library
      return library_code if location.blank? || location[:holding_library].blank? || location[:holding_library][:code].blank?
      location[:holding_library][:code]
    end

    def ask_me?
      services.include?('ask_me')
    end

    def open_libraries
      ['firestone', 'annex', 'marquand', 'mendel', 'stokes', 'eastasian', 'arch', 'lewis', 'engineer', 'recap']
    end

    def location_code
      return nil if location.blank?
      location['code']
    end

    def location_label
      return nil if location.blank? || location["library"].blank?
      label = location["library"]["label"]
      label += " - #{location['label']}" if location["label"].present?
      label
    end

    def item_location_code
      if item? && item["location"].present?
        item['location'].to_s
      else
        location_code
      end
    end

    def library_code
      return nil if location['library'].blank?
      location['library']['code']
    end

    def held_at_marquand_library?
      library_code == 'marquand' && !recap?
    end

    def clancy_item
      @clancy_item ||= Requests::ClancyItem.new(barcode: barcode)
    end

    def item_at_clancy?
      held_at_marquand_library? && clancy_item.at_clancy?
    end

    def available?
      (always_requestable? && !held_at_marquand_library?) || item.available?
      # This dealt with no item records be "available" but broke a bunch of other tests
      # ((always_requestable? && !held_at_marquand_library?) || (!has_item_data? || item.available?))
    end

    def cul_avery?
      return false unless item?
      item[:collection_code].present? && item[:collection_code] == 'AR'
    end

    def cul_music?
      return false unless item?
      item[:collection_code].present? && item[:collection_code] == 'MR'
    end

    def hl_art?
      return false unless item?
      item[:collection_code].present? && item[:collection_code] == 'FL'
    end

    def resource_shared?
      library_code == "RES_SHARE"
    end

    private

      def scsb_edd_collection_codes
        %w[AR BR CA CH CJ CP CR CU EN EV GC GE GS HS JC JD LD LE ML SW UT NA NH NL NP NQ NS NW GN JN JO PA PB PN GP JP] +
          %w[AH DL FL GUT HB HC HJ HK HL HS HW HY MCZ ML TZ WL] # Harvard collections available to digitize
      end

      def location_valid?
        location.key?(:library) && location[:library].key?(:code)
      end

      def in_process_statuses
        ["Acquisition technical services", "Acquisitions and Cataloging", "In Process"]
      end
  end
end
