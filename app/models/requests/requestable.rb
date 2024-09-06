# frozen_string_literal: true
module Requests
  # This class describes a resource that a
  # library patron might wish to request
  class Requestable
    attr_reader :bib
    attr_reader :item
    attr_reader :location
    attr_reader :call_number
    attr_reader :title
    attr_reader :user_barcode
    attr_reader :patron
    attr_reader :services

    delegate :pageable_loc?, to: :@pageable
    delegate :map_url, to: :@mappable
    delegate :illiad_request_url, :illiad_request_parameters, to: :@illiad
    delegate :eligible_for_library_services?, to: :@patron

    include Requests::Aeon

    # @param bib [Hash] Solr Document of the Top level Request
    # @param holding [Hash] Bib Data information on where the item is held (Marc liberation) parsed solr_document[holdings_1display] json
    # @param item [Hash] Item level data from bib data (https://bibdata.princeton.edu/availability?id= or mfhd=)
    # @param location [Hash] The hash for a bib data holding (https://bibdata.princeton.edu/locations/holding_locations)
    # @param patron [Patron] the patron information about the current user
    def initialize(bib:, holding: nil, item: nil, location: nil, patron:)
      @bib = bib
      @holding = Holding.new holding
      # Item inherits from SimpleDelegator which requires at least one argument
      # The argument is the Object that SimpleDelegator will delegate to.
      @item = item.present? ? Item.new(item) : NullItem.new({})
      @location = location
      @services = []
      @patron = patron
      @user_barcode = patron.barcode
      @call_number = @holding.holding_data['call_number_browse']
      @title = bib[:title_citation_display]&.first
      @pageable = Pageable.new(call_number:, location_code: location_object.code)
      @mappable = Requests::Mapable.new(bib_id: bib[:id], holdings: holding, location_code: location_object.code)
      @illiad = Requests::Illiad.new(enum: item&.fetch(:enum, nil), chron: item&.fetch(:chron, nil), call_number:)
    end

    delegate :pick_up_location_code, :item_type, :enum_value, :cron_value, :item_data?,
             :temp_loc_other_than_resource_sharing?, :on_reserve?, :enumerated?, :item_type_non_circulate?, :partner_holding?,
             :id, :use_statement, :collection_code, :charged?, :status, :status_label, :barcode?, :barcode, :preservation_conservation?, to: :item

    delegate :annex?, :location_label, to: :location_object

    def holding
      @holding.to_h
    end

    def thesis?
      @holding.thesis?
    end

    def numismatics?
      @holding.numismatics?
    end

    # Reading Room Request
    def aeon?
      location_object.aeon? || (use_statement == 'Supervised Use')
    end

    def recap?
      return false unless location_valid?
      location[:remote_storage] == "recap_rmt"
    end

    def recap_pf?
      return false unless recap?
      location_object.code == "firestone$pf"
    end

    def clancy?
      return false unless held_at_marquand_library?
      clancy_item.at_clancy? && clancy_item.available?
    end

    def recap_edd?
      return location[:recap_electronic_delivery_location] == true unless partner_holding?
      in_scsb_edd_collection? && !scsb_in_library_use?
    end

    def preservation?
      location_object.code == 'pres'
    end

    def circulates?
      item_type_non_circulate? == false && location[:circulates] == true
    end

    def location_code
      location_object.code
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
      location_object.holding_library&.dig(:code) || library_code
    end

    def ask_me?
      services.include?('ask_me')
    end

    def item_location_code
      item&.location || location_object.code
    end

    def held_at_marquand_library?
      library_code == 'marquand' && !recap?
    end

    def clancy_item
      @clancy_item ||= Requests::ClancyItem.new(barcode:)
    end

    def item_at_clancy?
      held_at_marquand_library? && clancy_item.at_clancy?
    end

    def available?
      (always_requestable? && !held_at_marquand_library?) || item.available?
    end

    def cul_avery?
      item&.collection_code == 'AR'
    end

    def cul_music?
      item&.collection_code == 'MR'
    end

    def hl_art?
      item&.collection_code == 'FL'
    end

    def replace_existing_services(new_services)
      @services = new_services
    end

    private

      # Location data presented as an object, rather than a hash.
      # The goal is to gradually replace all uses of the hash with
      # this object, so that other classes don't need to know the
      # exact hash keys to use in order to get the needed data.
      def location_object
        @location_object ||= Location.new location
      end

      delegate :library_code, to: :location_object

      def in_scsb_edd_collection?
        scsb_edd_collection_codes =
          %w[AR BR CA CH CJ CP CR CU EN EV GC GE GS HS JC JD LD LE ML SW UT NA NH NL NP NQ NS NW GN JN JO PA PB PN GP JP] +
          %w[AH DL FL GUT HB HC HJ HK HL HS HW HY MCZ ML TZ WL] # Harvard collections available to digitize
        scsb_edd_collection_codes.include?(collection_code)
      end

      def location_valid?
        location_object.valid?
      end

      def in_process_statuses
        ["Acquisition technical services", "Acquisitions and Cataloging", "In Process"]
      end
  end
end
