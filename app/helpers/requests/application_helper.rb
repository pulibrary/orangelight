# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength
module Requests
  module ApplicationHelper
    def format_label(key)
      label = key.to_s
      human_label = label.tr('_', ' ')
      formatted = human_label.split.map(&:capitalize).join(' ')
      formatted
    end

    def error_key_format(key)
      keys_to_ignore = ['items']
      format_label(key) unless keys_to_ignore.include? key.to_s
    end

    # array of error_keys
    def guest_user_error?(error_keys)
      user_errors = [:email, :user_name, :barcode]
      error_keys.any? { |item| user_errors.include? item }
    end

    def show_pick_up_service_options(requestable, mfhd_id)
      if requestable.on_shelf?
        display_on_shelf(requestable, mfhd_id)
      else
        display_requestable_list(requestable)
      end
    end

    # :reek:FeatureEnvy
    def show_service_options(requestable, _mfhd_id)
      if requestable.charged? && !requestable.aeon? && !requestable.ask_me?
        render partial: 'checked_out_options', locals: { requestable: }
      else
        display_requestable_list(requestable)
      end
    end

    def hidden_service_options(requestable, fill_in: false)
      return hidden_service_options_fill_in(requestable) if fill_in
      hidden = output_request_input(requestable)
      return hidden if hidden.present?

      if requestable.services.include? 'recap'
        recap_print_only_input requestable
      else
        request_input(requestable.services.first)
      end
    end

    def output_request_input(requestable)
      output = ""
      ['annex', 'pres', 'ppl', 'lewis', 'paging', 'on_order', 'on_shelf'].each do |type|
        next unless requestable.services.include?(type)
        output = request_input(type)
        break
      end
      output
    end

    # only requestable services that support "user-supplied volume info"
    def hidden_service_options_fill_in(requestable)
      if requestable.annex?
        request_input('annex')
      elsif requestable.services.include? 'recap_no_items'
        request_input('recap_no_items')
      else
        request_input('paging')
      end
    end

    def recap_print_only_input(requestable)
      content_tag(:fieldset, class: 'recap--print', id: "recap_group_#{requestable.preferred_request_id}") do
        concat hidden_field_tag "requestable[][type]", "", value: 'recap'
      end
    end

    # rubocop:disable Style/NumericPredicate
    def enum_copy_display(item)
      return "" if item.blank?
      [item.description, item.copy_value].join(" ").strip
    end
    # rubocop:enable Style/NumericPredicate

    def request_input(type)
      hidden_field_tag "requestable[][type]", "", value: type
    end

    def gfa_lookup(lib_code)
      if lib_code == "firestone"
        "PA"
      else
        lib = Requests::BibdataService.delivery_locations.select { |_key, hash| hash["library"]["code"] == lib_code }
        lib.keys.first.to_s
      end
    end

    def pick_up_classlist(requestable, collapse)
      class_list = "collapse request--print"
      class_list += " show" if !requestable.digitize? && !collapse
      class_list
    end

    # move this to requestable object
    # Default pick-ups should be available
    def pick_up_choices(requestable, default_pick_ups, collapse = false)
      content_tag(:div, id: "fields-print__#{requestable.preferred_request_id}", class: pick_up_classlist(requestable, collapse)) do
        preferred_request_content_tag(requestable, requestable.pick_up_locations || default_pick_ups)
      end
    end

    # :reek:NilCheck
    def preferred_request_content_tag(requestable, default_pick_ups)
      (show_pick_up_service_options(requestable, nil) || "".html_safe) +
        content_tag(:div, id: "fields-print__#{requestable.preferred_request_id}_card", class: "card card-body bg-light") do
          locs = pick_up_locations(requestable, default_pick_ups)

          name = 'requestable[][pick_up]'
          id = "requestable__pick_up_#{requestable.preferred_request_id}"
          if locs.size > 1
            prompt_text = custom_pickup_prompt(requestable, locs) || I18n.t("requests.default.pick_up_placeholder")
            selected_value = find_selected_pickup_value(requestable, locs)
            # For ReCAP items, select the empty prompt instead of any actual option
            selected_value = '' if requestable.recap? && selected_value.nil?
            options = [[prompt_text, '', { disabled: true, selected: false }]] + locs.map { |loc| [loc[:label], { 'pick_up' => loc[:gfa_pickup], 'pick_up_location_code' => loc[:pick_up_location_code] }.to_json] }
            select_tag name.to_s, options_for_select(options, selected_value), id: id
          else

            single_pickup(requestable.charged?, name, id, locs[0])
          end
        end
    end

    # rubocop:disable Rails/OutputSafety
    def hidden_fields_mfhd(mfhd)
      hidden = ""
      return hidden if mfhd.nil?
      hidden += hidden_field_tag "mfhd[][call_number]", "", value: (mfhd['call_number']).to_s unless mfhd["call_number"].nil?
      hidden += hidden_field_tag "mfhd[][location]", "", value: (mfhd['location']).to_s unless mfhd["location"].nil?
      hidden += hidden_field_tag "mfhd[][library]", "", value: (mfhd['library']).to_s
      hidden.html_safe
    end
    # rubocop:enable Rails/OutputSafety

    def suppress_login?(request)
      request.only_aeon?
    end

    def item_checkbox(requestable, single_item_form)
      disabled = !requestable.will_submit_via_form?
      check_box_tag "requestable[][selected]", true, check_box_selected?(disabled, single_item_form), class: 'request--select', disabled:, aria: { labelledby: "title enum_#{requestable.preferred_request_id}" }, id: "requestable_selected_#{requestable.preferred_request_id}"
    end

    ## If any requestable items have a temp location assume everything at the holding is in a temp loc?
    def current_location_label(holding_location_label, requestable_list)
      first_location = requestable_list.first.location
      location_label = first_location.short_label.blank? ? "" : "- #{first_location.short_label}"
      label = if requestable_list.first.temp_loc_other_than_resource_sharing?
                "#{first_location.library_label}#{location_label}"
              else
                holding_location_label
              end
      "#{label} #{requestable_list.first.call_number}"
    end

    def check_box_selected?(disabled, single_item_form)
      if single_item_form
        !disabled
      else
        false
      end
    end

    def submit_button_disabled?(requestable_list)
      # temporary chane issue 438 guest can no longer check out materials
      return true if @user.blank? || @user.guest
      return unsubmittable? requestable_list unless requestable_list.size == 1
      # temporary changes issue 438 do not disable the button for circulating items
      # requestable_list.first.services.empty? || requestable_list.first.on_reserve? || (requestable_list.first.services.include? 'on_shelf') || requestable_list.first.ask_me?
      requestable_list.first.services.empty? || requestable_list.first.on_reserve?
    end

    def unsubmittable?(requestable_list)
      !requestable_list.any? { |requestable| (requestable.services | submitable_services).present? }
    end

    def submitable_services
      ['on_shelf', 'in_process', 'on_order', 'annex', 'recap', 'recap_edd', 'paging', 'recap_no_items', 'ppl', 'lewis']
    end

    def submit_message(requestable_list)
      single_item = "Request this Item"
      multi_item = "Request Selected Items"
      no_item = "No Items Available"
      return multi_item unless requestable_list.size == 1
      if requestable_list.first.services.empty?
        no_item
      elsif requestable_list.first.annex?
        # Annex items have the potential to display the
        # use the fill-in form, where a user could potentially
        # request multiple volumes.  For that reason, we show
        # the plural form "Request Selected Items" in this case
        multi_item
      else
        single_item
      end
    end

    # only show the table sort if there are enough items
    # to make it worthwhile
    def show_tablesorter(requestable_list)
      return "tablesorter" if table_sorter_present?(requestable_list)
      ""
    end

    def table_sorter_present?(requestable_list)
      requestable_list.size > 5
    end

    def display_label
      {
        author: "Author/Artist",
        title: "Title",
        date: "Published/Created",
        id: "Bibliographic ID",
        mfhd: "Holding ID (mfhd)"
      }.with_indifferent_access
    end

    def display_status(requestable)
      content_tag(:span, requestable.item['status']) unless requestable.item.nil?
    end

    def system_status_label(requestable)
      return "" if requestable.item.blank?
      content_tag(:div, requestable.item[:status], class: 'system-status')
    end

    def display_urls(requestable)
      content_tag :ol do
        requestable.urls.each do |key, value|
          unless key == 'iiif_manifest_paths'
            value.reverse!
            concat content_tag(:li, link_to(value.join(": "), key), class: 'link')
          end
        end
      end
    end

    def self.recap_annex_available_pick_ups(requestable, default_pick_ups)
      locations = requestable.pick_up_locations || default_pick_ups
      pick_ups = locations.select { |loc| Requests::Location.valid_recap_annex_pickup?(loc) }
      pick_ups << default_pick_ups[0] if pick_ups.empty?
      pick_ups
    end

    private

      def custom_pickup_prompt(requestable, locs)
        # For ReCAP items, return nil to use default prompt
        return nil if requestable.recap?

        holding_library = normalize_holding_library(requestable)
        return nil if holding_library.blank?

        find_prompt_for_holding_library(holding_library, locs)
      end

      # :reek:UtilityFunction
      def normalize_holding_library(requestable)
        requestable.holding_library&.downcase
      end

      def find_prompt_for_holding_library(holding_library, locs)
        # Check for special engineering library cases first
        engineering_prompt = engineering_library_prompt(holding_library, locs)
        return engineering_prompt if engineering_prompt

        # Find matching library by code and suggest it in the prompt
        suggested_location = find_matching_location_label(holding_library, locs)
        return unless suggested_location
        I18n.t('requests.pick_up_suggested.holding_library', holding_library: suggested_location)
        # "Select a Delivery Location (Recommended: #{suggested_location})"
      end

      def find_matching_location_label(holding_library, locs)
        matching_loc = find_matching_location_by_code(holding_library, locs)
        matching_loc&.dig(:label)
      end

      # :reek:UtilityFunction
      def find_matching_location_by_code(holding_library, locs)
        locs.find do |loc|
          # Extract library code and compare with holding library
          location = Requests::Location.new(loc)
          location.library_code&.downcase == holding_library
        end
      end

      # :reek:UtilityFunction
      def engineering_library_prompt(holding_library, locs)
        # Special case: lewis, plasma should default to Engineering Library
        if ['lewis', 'plasma'].include?(holding_library)
          engineering_loc = locs.find { |loc| loc[:label] == "Engineering Library" }
          return I18n.t('requests.pick_up_suggested.engineering_holding_library', engineering_holding_library: engineering_loc[:label]) if engineering_loc
        end
        nil
      end

      def find_selected_pickup_value(requestable, locs)
        return nil if should_skip_form_preselection?(requestable)

        holding_library = normalize_holding_library(requestable)
        return nil if holding_library.blank?

        find_form_preselected_location_json(holding_library, locs)
      end

      # :reek:UtilityFunction
      def should_skip_form_preselection?(requestable)
        requestable.recap?
      end

      def find_form_preselected_location_json(holding_library, locs)
        selected_location = find_engineering_location(holding_library, locs) ||
                            find_matching_location_by_code(holding_library, locs)
        return nil unless selected_location

        location_to_json(selected_location)
      end

      # :reek:UtilityFunction
      def find_engineering_location(holding_library, locs)
        return nil unless ['lewis', 'plasma'].include?(holding_library)
        locs.find { |loc| Requests::Location.new(loc).engineering_library? }
      end

      # :reek:UtilityFunction
      def location_to_json(location)
        { 'pick_up' => location[:gfa_pickup], 'pick_up_location_code' => location[:pick_up_location_code] }.to_json
      end

      def display_requestable_list(requestable)
        content_tag(:ul, class: "service-list") do
          if requestable.ill_eligible?
            concat content_tag(:li, sanitize(I18n.t("requests.ill.brief_msg")), class: "service-item")
          else
            # there are no instances where more than one actual service is available to an item, so we are going to take the first service that is not edd
            filtered_services = if requestable.services.size == 1 && requestable.services.first.include?("edd")
                                  requestable.services
                                else
                                  requestable.services.reject { |service_name| service_name.include?("edd") }
                                end
            # if there is not a valid service this will evaluate to `requests.brief_msg` and display an error message.
            brief_msg = if filtered_services.first
                          I18n.t("requests.#{filtered_services.first}.brief_msg")
                        else
                          I18n.t("requests.alma_login.no_access")
                        end
            concat content_tag(:li, sanitize(brief_msg), class: "service-item")
          end
        end
      end

      def display_on_shelf(requestable, _mfhd_id)
        content_tag(:div) do
          display_requestable_list(requestable)
        end
      end

      def pick_up_locations(requestable, default_pick_ups)
        # we don't want to change the ill_eligible rules
        return ill_eligible_pick_up_location(default_pick_ups) if requestable.ill_eligible?
        return Requests::ApplicationHelper.recap_annex_available_pick_ups(requestable, default_pick_ups) if requestable.recap? || requestable.annex?
        return default_pick_ups if requestable.location&.standard_circ_location?
        if requestable.delivery_location_label.present?
          [{ label: requestable.delivery_location_label, gfa_pickup: requestable.delivery_location_code, pick_up_location_code: requestable.pick_up_location_code, staff_only: false }]
        else
          [{ label: requestable.location.library_label, gfa_pickup: gfa_lookup(requestable.location.library_code), staff_only: false }]
        end
      end

      # :reek:UtilityFunction
      def ill_eligible_pick_up_location(default_pick_ups)
        # currently for resource sharing items through Illiad we use firestone Library with gfa_pickup of PA
        location = default_pick_ups.find { |location| location[:gfa_pickup] == "PA" }
        [location].compact
      end

      def single_pickup(is_charged, name, id, location)
        style = if is_charged
                  'margin-top:10px;'
                else
                  ''
                end
        hidden = hidden_field_tag name.to_s, "", value: { 'pick_up' => location[:gfa_pickup], 'pick_up_location_code' => location[:pick_up_location_code] }.to_json, class: 'single-pick-up-hidden', id: id
        label = label_tag id, "Pick-up location: #{location[:label]}", class: 'single-pick-up', style: style.to_s
        hidden + label
      end
  end
end
# rubocop:enable Metrics/ModuleLength
