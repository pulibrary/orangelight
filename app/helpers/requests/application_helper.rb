# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength
module Requests
  module ApplicationHelper
    def format_email(email)
      email&.downcase
    end

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

    def show_service_options(requestable, _mfhd_id)
      if requestable.no_services?
        content_tag(:div, "#{requestable.title} #{enum_copy_display(requestable.item)} #{sanitize(I18n.t('requests.no_services.brief_msg'))}", class: 'sr-only') +
          content_tag(:div, sanitize(I18n.t("requests.no_services.brief_msg")), class: 'service-item', aria: { hidden: true })
      elsif requestable.charged? && !requestable.aeon? && !requestable.ask_me?
        render partial: 'checked_out_options', locals: { requestable: requestable }
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
      ['annex', 'bd', 'pres', 'ppl', 'lewis', 'paging', 'on_order', 'trace', 'on_shelf'].each do |type|
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
      # id = requestable.item? ? requestable.item['id'] : requestable.holding['id']
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

    def preferred_request_content_tag(requestable, default_pick_ups)
      (show_pick_up_service_options(requestable, nil) || "") +
        content_tag(:div, id: "fields-print__#{requestable.preferred_request_id}_card", class: "card card-body bg-light") do
          locs = pick_up_locations(requestable, default_pick_ups)
          # temporary changes issue 438
          name = 'requestable[][pick_up]'
          id = "requestable__pick_up_#{requestable.preferred_request_id}"
          if locs.size > 1
            select_tag name.to_s, options_for_select(locs.map { |loc| [loc[:label], { 'pick_up' => loc[:gfa_pickup], 'pick_up_location_code' => loc[:pick_up_location_code] }.to_json] }), prompt: I18n.t("requests.default.pick_up_placeholder"), id: id
          else
            single_pickup(requestable.charged?, name, id, locs[0])
          end
        end
    end

    def available_pick_ups(requestable, default_pick_ups)
      idx = (default_pick_ups.map { |loc| loc[:label] }).index(requestable.location["library"]["label"]) # || 0
      if idx.present?
        [default_pick_ups[idx]]
      elsif requestable.recap? || requestable.annex?
        locations = requestable.pick_up_locations || default_pick_ups
        # open libraries
        pick_ups = locations.select { |loc| ['PJ', 'PA', 'PL', 'PK', 'PM', 'QX', 'PW', 'PN', 'QA', 'QT', 'QC'].include?(loc[:gfa_pickup]) }
        pick_ups << default_pick_ups[0] if pick_ups.empty?
        pick_ups
      else
        [default_pick_ups[0]]
      end
      # return
      # temporary only deliver to holding library or firestone
      # locs = []
      # if requestable.services.include? 'trace'
      #   locs = default_pick_ups
      # elsif requestable.pick_up_locations.nil?
      #   locs = default_pick_ups
      # else
      #   requestable.pick_up_locations.each do |location|
      #     locs << { label: location[:label], gfa_pickup: location[:gfa_pickup], staff_only: location[:staff_only] }
      #   end
      # end
      # locs
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

    def hidden_fields_item(requestable)
      request_id = requestable.preferred_request_id
      hidden = hidden_field_tag "requestable[][bibid]", "", value: requestable.bib[:id].to_s, id: "requestable_bibid_#{request_id}"
      hidden += hidden_field_tag "requestable[][mfhd]", "", value: requestable.holding.keys[0].to_s, id: "requestable_mfhd_#{request_id}"
      hidden += hidden_field_tag "requestable[][call_number]", "", value: (requestable.holding.first[1]['call_number']).to_s, id: "requestable_call_number_#{request_id}" unless requestable.holding.first[1]["call_number"].nil?
      hidden += hidden_field_tag "requestable[][location_code]", "", value: requestable.item_location_code.to_s, id: "requestable_location_#{request_id}"
      hidden += if requestable.item?
                  hidden_fields_for_item(item: requestable.item, preferred_request_id: requestable.preferred_request_id)
                else
                  hidden_field_tag("requestable[][item_id]", "", value: requestable.preferred_request_id, id: "requestable_item_id_#{requestable.preferred_request_id}")
                end
      hidden += hidden_fields_for_scsb(item: requestable.item) if requestable.partner_holding?
      hidden
    end

    def hidden_fields_holding(requestable)
      hidden = hidden_field_tag "requestable[][mfhd]", "", value: requestable.holding.keys[0].to_s, id: "requestable_mfhd_#{requestable.holding.keys[0]}"
      hidden += hidden_field_tag "requestable[][call_number]", "", value: (requestable.holding.first[1]['call_number']).to_s, id: "requestable_call_number_#{requestable.holding.keys[0]}" unless requestable.holding.first[1]["call_number"].nil?
      hidden += hidden_field_tag "requestable[][location_code]", "", value: (requestable.holding.first[1]['location_code']).to_s, id: "requestable_location_code_#{requestable.holding.keys[0]}"
      hidden += hidden_field_tag "requestable[][location]", "", value: (requestable.holding.first[1]['location']).to_s, id: "requestable_location_#{requestable.holding.keys[0]}"
      sanitize(hidden, tags: input)
    end

    def hidden_fields_borrow_direct(request)
      hidden_bd_tags = ''
      hidden_bd_tags += hidden_field_tag 'bd[auth_id]', '', value: ''
      hidden_bd_tags += hidden_field_tag 'bd[query_params]', '', value: request.isbn_numbers.first
      sanitize(hidden_bd_tags, tags: input)
    end

    def isbn_string(array_of_isbns)
      array_of_isbns.join(',')
    end

    def suppress_login(request)
      request.only_aeon?
    end

    def item_checkbox(requestable, single_item_form)
      disabled = !requestable.will_submit_via_form?
      check_box_tag "requestable[][selected]", true, check_box_selected(requestable, disabled, single_item_form), class: 'request--select', disabled: disabled, aria: { labelledby: "title enum_#{requestable.preferred_request_id}" }, id: "requestable_selected_#{requestable.preferred_request_id}"
    end

    ## If any requestable items have a temp location assume everything at the holding is in a temp loc?
    def current_location_label(mfhd_label, requestable_list)
      location_label = requestable_list.first.location['label'].blank? ? "" : "- #{requestable_list.first.location['label']}"
      label = if requestable_list.first.temp_loc?.present? && !requestable_list.first.in_resource_sharing?
                "#{requestable_list.first.location['library']['label']}#{location_label}"
              else
                mfhd_label
              end
      "#{label} #{requestable_list.first.call_number}"
    end

    def check_box_selected(requestable, disabled, single_item_form)
      if single_item_form
        if requestable.charged? || requestable.services.empty?
          false
        else
          !disabled
        end
      else
        false
      end
    end

    def submit_button_disabled(requestable_list)
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
      ['on_shelf', 'in_process', 'on_order', 'annex', 'recap', 'recap_edd', 'paging', 'bd', 'recap_no_items', 'ppl', 'lewis']
    end

    def submit_message(requestable_list)
      single_item = "Request this Item"
      multi_item = "Request Selected Items"
      no_item = "No Items Available"
      return multi_item unless requestable_list.size == 1
      if requestable_list.first.services.empty?
        no_item
      elsif requestable_list.first.charged?
        return multi_item if requestable_list.first.annex? || requestable_list.first.pageable_loc?
        single_item # no_item
      else
        submit_message_for_requestable_items(requestable_list)
      end
    end

    def submit_message_for_requestable_items(requestable_list)
      single_item = "Request this Item"
      multi_item = "Request Selected Items"
      trace = "Trace this item"
      if requestable_list.first.annex? || requestable_list.first.pageable_loc?
        multi_item
      elsif requestable_list.first.traceable?
        trace
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

    # def display_language
    #   {
    #     language: "Language:"
    #   }.with_indifferent_access
    # end

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

    private

      def display_requestable_list(requestable)
        return if requestable.no_services?
        content_tag(:ul, class: "service-list") do
          if requestable.borrow_direct? || requestable.ill_eligible?
            concat content_tag(:li, sanitize(I18n.t("requests.ill.brief_msg")), class: "service-item")
          else
            # there are no instances where more than one actual service is available to an item, so we are going to take the first service that is not edd
            filtered_services = requestable.services.reject { |service_name| service_name.include?("edd") }
            brief_msg = I18n.t("requests.#{filtered_services.first}.brief_msg")
            concat content_tag(:li, sanitize(brief_msg), class: "service-item")
          end
        end
      end

      def display_on_shelf(requestable, _mfhd_id)
        content_tag(:div) do
          display_requestable_list(requestable)
          # temporary changes issue 438
          # concat link_to 'Where to find it', requestable.map_url(mfhd_id)
          # concat content_tag(:div, sanitize(I18n.t("requests.trace.brief_msg")), class: 'service-item') if requestable.traceable?
        end
      end

      def pick_up_locations(requestable, default_pick_ups)
        return [default_pick_ups[0]] if requestable.borrow_direct? || requestable.ill_eligible?
        return available_pick_ups(requestable, default_pick_ups) unless requestable.pending?
        if requestable.delivery_location_label.present?
          [{ label: requestable.delivery_location_label, gfa_pickup: requestable.delivery_location_code, pick_up_location_code: requestable.pick_up_location_code, staff_only: false }]
        else
          # TODO: Why is this option here
          [{ label: requestable.location[:library][:label], gfa_pickup: gfa_lookup(requestable.location[:library][:code]), staff_only: false }]
        end
      end

      def hidden_fields_for_item(item:, preferred_request_id:)
        hidden = hidden_field_tag("requestable[][item_id]", "", value: preferred_request_id.to_s, id: "requestable_item_id_#{preferred_request_id}")
        hidden += hidden_field_tag("requestable[][barcode]", "", value: item['barcode'].to_s, id: "requestable_barcode_#{preferred_request_id}") unless item["barcode"].nil?
        hidden += hidden_field_tag("requestable[][enum]", "", value: item.enum_value.to_s, id: "requestable_enum_#{preferred_request_id}") if item.enum_value.present?
        hidden += hidden_field_tag("requestable[][copy_number]", "", value: item.copy_number.to_s, id: "requestable_copy_number_#{preferred_request_id}")
        hidden + hidden_field_tag("requestable[][status]", "", value: item['status'].to_s, id: "requestable_status_#{preferred_request_id}")
      end

      def hidden_fields_for_scsb(item:)
        hidden = hidden_field_tag("requestable[][cgd]", "", value: item['cgd'].to_s, id: "requestable_cgd_#{item['id']}")
        hidden += hidden_field_tag("requestable[][cc]", "", value: item['collection_code'].to_s, id: "requestable_collection_code_#{item['id']}")
        hidden + hidden_field_tag("requestable[][use_statement]", "", value: item['use_statement'].to_s, id: "requestable_use_statement_#{item['id']}")
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
