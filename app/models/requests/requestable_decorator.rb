# frozen_string_literal: true
module Requests
  class RequestableDecorator
    delegate :system_id, :services, :charged?, :annex?, :on_reserve?,
             :ask_me?, :aeon_request_url, :temp_loc_other_than_resource_sharing?, :call_number, :eligible_for_library_services?,
             :holding_library_in_library_only?, :holding_library, :bib, :circulates?, :item_data?, :recap_edd?, :clancy_available?,
             :holding, :item_location_code, :item?, :item, :partner_holding?, :status, :status_label, :use_restriction?, :library_code, :enum_value, :item_at_clancy?,
             :cron_value, :illiad_request_parameters, :location_label, :aeon?, :patron, :held_at_marquand_library?,
             :ill_eligible?, :scsb_in_library_use?, :pick_up_locations, :on_shelf?, :pending?, :recap?, :recap_pf?, :illiad_request_url, :available?,
             :on_order?, :in_process?, :alma_managed?, :title, :cul_avery?, :cul_music?,
             :pick_up_location_code, :enumerated?, to: :requestable
    delegate :content_tag, :hidden_field_tag, :concat, to: :view_context

    alias bib_id system_id

    attr_reader :requestable, :view_context
    def initialize(requestable, view_context)
      @requestable = requestable
      @view_context = view_context
    end

    ## If the item doesn't have any item level data use the holding mfhd ID as a unique key
    ## when one is needed. Primarily for non-barcoded Annex items.
    def preferred_request_id
      requestable.id.presence || holding.mfhd_id
    end

    def digitize?
      return false unless patron.cas_provider? # only allow digitization for cas users
      eligible_for_library_services? && (item_data? || !circulates?) && (on_shelf_edd? || recap_edd? || marquand_edd?) && !request_status?
    end

    def fill_in_digitize?
      return false unless patron.cas_provider? # only allow fill in digitization for cas users
      !item_data? || digitize?
    end

    def pick_up?
      return false if !eligible_for_library_services? || (!patron.cas_provider? && !off_site?)
      item_data? && (on_shelf? || recap? || annex?) && circulates? && !holding_library_in_library_only? && !scsb_in_library_use? && !request_status?
    end

    def fill_in_pick_up?
      return false unless eligible_for_library_services?
      !item_data? || pick_up?
    end

    def request?
      return false unless eligible_for_library_services?
      request_status?
    end

    def request_status?
      on_order? || in_process? || ill_eligible? || services.empty?
    end

    def will_submit_via_form?
      return false unless eligible_for_this_item?
      digitize? || pick_up? || scsb_in_library_use? || ill_eligible? || on_order? || in_process? || off_site?
    end

    def on_shelf_edd?
      services.include?('on_shelf_edd')
    end

    def marquand_edd?
      !(['clancy_edd', 'clancy_unavailable', 'marquand_edd'] & services).empty?
    end

    def in_library_use_required?
      available? && (!held_at_marquand_library? || !item_at_clancy? || clancy_available?) && ((off_site? && !circulates?) || holding_library_in_library_only? || scsb_in_library_use?)
    end

    def off_site?
      recap? || annex? || item_at_clancy? || held_at_marquand_library?
    end

    def off_site_location
      if clancy_available?
        "clancy" # at clancy and available
      elsif item_at_clancy?
        "clancy_unavailable" # at clancy but not available
      elsif recap? && (holding_library == "marquand" || requestable.cul_avery?)
        "recap_marquand"
      elsif recap?
        "recap"
      else
        library_code
      end
    end

    def create_fill_in_requestable
      fill_in_req = Requestable.new(bib:, holding:, item: nil, location: location.to_h, patron:)
      fill_in_req.replace_existing_services services
      RequestableDecorator.new(fill_in_req, view_context)
    end

    def libcal_url
      code = if off_site? && !held_at_marquand_library? && location.holding_library.present?
               location.holding_library[:code]
             elsif !off_site? || held_at_marquand_library?
               location.library_code
             else
               "firestone"
             end
      Libcal.url(code)
    end

    def status_badge
      content_tag(:span, requestable.status, class: "availability--label badge #{css_class}")
    end

    def css_class
      if requestable.status == "Available"
        "bg-success"
      else
        "bg-danger"
      end
    end

    def aeon_url(_request_ctx)
      if requestable.alma_managed?
        requestable.aeon_request_url
      else
        aeon_url = Requests.config[:aeon_base]
        "#{aeon_url}?#{requestable.aeon_mapped_params.to_query}"
      end
    end

    def delivery_location_label
      if requestable.held_at_marquand_library? ||
         (recap? && (requestable.holding_library == "marquand" || requestable.cul_avery? || requestable.hl_art?))
        "Marquand Library at Firestone"
      elsif requestable.cul_music?
        "Mendel Music Library"
      else
        first_delivery_location[:label]
      end
    end

    def delivery_location_code
      if requestable.cul_avery? || requestable.hl_art?
        "PJ"
      elsif requestable.cul_music?
        "PK"
      else
        first_delivery_location[:gfa_pickup] || "PA"
      end
    end

    def no_services?
      !(digitize? || pick_up? || aeon? || ill_eligible? || in_library_use_required? || request? || on_shelf? || off_site?)
    end

    def location
      Location.new requestable.location
    end

    private

      def first_delivery_location
        delivery_locations = Location.new(requestable.location).delivery_locations
        if delivery_locations.blank?
          {}
        else
          delivery_locations.first
        end
      end

      def eligible_for_this_item?
        return false unless eligible_for_library_services?

        patron.cas_provider? || (patron.alma_provider? && off_site? && (available? || in_process?))
      end
  end
end
