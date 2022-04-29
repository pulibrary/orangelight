# frozen_string_literal: true
module Requests
  class RequestableDecorator
    delegate :system_id, :aeon_mapped_params, :services, :charged?, :annex?, :lewis?, :pageable_loc?, :traceable?, :on_reserve?,
             :ask_me?, :etas?, :etas_limited_access, :aeon_request_url, :location, :temp_loc?, :call_number, :eligible_to_pickup?, :eligible_for_library_services?,
             :holding_library_in_library_only?, :holding_library, :bib, :circulates?, :open_libraries, :item_data?, :recap_edd?, :user_barcode, :clancy?,
             :holding, :item_location_code, :item?, :item, :partner_holding?, :status, :status_label, :use_restriction?, :library_code, :enum_value, :item_at_clancy?,
             :cron_value, :illiad_request_parameters, :location_label, :online?, :aeon?, :borrow_direct?, :patron, :held_at_marquand_library?,
             :ill_eligible?, :scsb_in_library_use?, :pick_up_locations, :on_shelf?, :pending?, :recap?, :recap_pf?, :illiad_request_url, :available?,
             :campus_authorized, :on_order?, :urls, :in_process?, :alma_managed?, :covid_trained?, :title, :map_url, :cul_avery?, :cul_music?,
             :pick_up_location_code, :resource_shared?, :enumerated?, to: :requestable
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
      requestable.id.presence || holding.first[0]
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
      return false if etas? || !eligible_to_pickup? || (!patron.cas_provider? && !off_site?)
      item_data? && (on_shelf? || recap? || annex?) && circulates? && !holding_library_in_library_only? && !scsb_in_library_use? && !request_status?
    end

    def fill_in_pick_up?
      return false unless eligible_to_pickup?
      !item_data? || pick_up?
    end

    def request?
      return false unless eligible_to_pickup?
      request_status?
    end

    def request_status?
      on_order? || in_process? || traceable? || borrow_direct? || ill_eligible? || services.empty?
    end

    def help_me?
      return false unless eligible_for_library_services?
      (request_status? && !eligible_to_pickup?) || # a requestable item that the user can not pick up
        ask_me? || # recap scsb in library only items
        (!located_in_an_open_library? && !aeon? && !resource_shared?) # item in a closed library that is not aeon managed or resource shared
    end

    def will_submit_via_form?
      return false unless eligible_for_this_item?
      digitize? || pick_up? || scsb_in_library_use? || (ill_eligible? && patron.covid_trained?) || on_order? || in_process? || traceable? || off_site? || help_me?
    end

    def located_in_an_open_library?
      open_libraries.include?(library_code)
    end

    def on_shelf_edd?
      services.include?('on_shelf_edd')
    end

    def marquand_edd?
      !(['clancy_edd', 'clancy_unavailable', 'marquand_edd'] & services).empty?
    end

    def in_library_use_required?
      !etas? && available? && (!held_at_marquand_library? || !item_at_clancy? || clancy?) && ((off_site? && !circulates?) || holding_library_in_library_only? || scsb_in_library_use?) && campus_authorized
    end

    def off_site?
      recap? || annex? || item_at_clancy? || held_at_marquand_library?
    end

    def off_site_location
      if clancy?
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
      fill_in_req = Requestable.new(bib: bib, holding: holding, item: nil, location: location, patron: patron)
      fill_in_req.services = services
      RequestableDecorator.new(fill_in_req, view_context)
    end

    def libcal_url
      code = if off_site? && !held_at_marquand_library? && location[:holding_library].present?
               location[:holding_library][:code]
             elsif !off_site? || held_at_marquand_library?
               location[:library][:code]
             else
               "firestone"
             end
      Libcal.url(code)
    end

    def status_badge
      css_class = if requestable.status == "Available"
                    "badge-success"
                  else
                    "badge-danger"
                  end
      status = if requestable.status_label.nil? || requestable.status == requestable.status_label
                 requestable.status
               else
                 requestable.status + ' - ' + requestable.status_label
               end
      content_tag(:span, status, class: "availability--label badge #{css_class}")
    end

    def help_me_message
      key = if patron.campus_authorized || !located_in_an_open_library? || (requestable.scsb_in_library_use? && requestable.etas?)
              "full_access"
            elsif !eligible_for_library_services?
              "cas_user_no_barcode_no_choice_msg"
            elsif eligible_to_pickup?
              "pickup_access"
            else
              "digital_access"
            end
      I18n.t("requests.help_me.brief_msg.#{key}_html").html_safe # rubocop:disable Rails/OutputSafety
    end

    def aeon_url(request_ctx)
      if requestable.alma_managed?
        requestable.aeon_request_url(request_ctx)
      else
        "#{Requests::Config[:aeon_base]}?#{requestable.aeon_mapped_params.to_query}"
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
      # elsif requestable.recap_pf?
      #   "PF"
      else
        first_delivery_location[:gfa_pickup] || "PA"
      end
    end

    def no_services?
      !(digitize? || pick_up? || aeon? || borrow_direct? || ill_eligible? || in_library_use_required? || help_me? || request? || online? || on_shelf? || off_site?)
    end

    private

      def first_delivery_location
        if requestable.location[:delivery_locations].blank? || requestable.location[:delivery_locations].empty?
          {}
        else
          requestable.location[:delivery_locations].first
        end
      end

      def eligible_for_this_item?
        return false unless eligible_for_library_services?

        patron.cas_provider? || (patron.alma_provider? && off_site? && (available? || in_process?))
      end
  end
end
