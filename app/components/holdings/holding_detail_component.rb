class Holdings::HoldingDetailComponent < ViewComponent::Base
  def initialize(holding, holding_id, adapter)
    @holding = holding
    @holding_id = holding_id
    @adapter = adapter
  end

  def call
    markup = ''
    temp_location_code = adapter.temp_location_code(holding)

    markup = holding_location if location_label.present?
    markup << call_number_link
    markup << if adapter.repository_holding?(holding)
                holding_location_repository
              elsif adapter.scsb_holding?(holding) && !adapter.empty_holding?(holding)
                holding_location_scsb
              elsif adapter.unavailable_holding?(holding)
                holding_location_unavailable
              else
                holding_location_default(doc_id,
                                         temp_location_code)
              end

    request_placeholder_markup = request_placeholder
    markup << request_placeholder_markup.html_safe

    markup << build_holding_notes

    markup = holding_block(markup) unless markup.empty?
    markup
  end

    private

      attr_reader :holding, :holding_id, :adapter

      def doc_id
        @doc_id ||= holding["mms_id"] || adapter.doc_id
      end

      def call_number
        @call_number ||= adapter.call_number(holding)
      end

      def location_rules
        @location_rules ||= adapter.holding_location_rules(holding)
      end

      def location_label
        @location_label ||= adapter.holding_location_label(holding)
      end

      # Generate the links for a specific holding
      # @param holding [Hash] the information for the holding
      # @param location [Hash] the location information for the holding
      # @param holding_id [String] the ID for the holding
      # @param call_number [String] the call number
      # @param [String] the markup
      def holding_location_container
        markup = holding_location_span
        link_markup = locate_link(holding['location_code'], call_number, holding['library'])
        markup << link_markup.html_safe
        markup
      end

      # Generate the markup block for a specific holding
      # @param holding [Hash] the information for the holding
      # @param holding_id [String] the ID for the holding
      # @param [String] the markup
      def holding_location
        holding_location_container
        markup = ''
        markup << content_tag(:td, location_label.html_safe,
                              class: 'library-location',
                              data: { holding_id: })
        markup
      end

      # Generate a <span> element for a holding location
      # @param location [String] the location value
      # @param holding_id [String] the ID for the holding
      # @return [String] <span> markup
      def holding_location_span
        content_tag(:span, location_label,
                    class: 'location-text',
                    data: { location: true, holding_id: })
      end

      # Generate the link for a specific holding
      # @param holding [Hash] the information for the holding
      # @param location [Hash] the location information for the holding
      # @param holding_id [String] the ID for the holding
      # @param call_number [String] the call number
      # @param library [String] the library in which the holding resides
      # @param [String] the markup
      def locate_link(location, call_number, library)
        locator = StackmapLocationFactory.new(resolver_service: ::StackmapService::Url)
        return '' if locator.exclude?(call_number:, library:)

        markup = ''
        markup = stackmap_span_markup(location, library) if helpers.find_it_location?(location)
        " #{markup}"
      end

      def stackmap_span_markup(location, library)
        content_tag(:span, '',
                    data: {
                      'map-location': location.to_s,
                      'location-library': library,
                      'location-name': holding['location']
                    })
      end

      # Generate <span> markup used in links for browsing by call numbers
      # @return [String] the markup
      def call_number_span
        %(<span class="link-text">#{I18n.t('blacklight.holdings.browse')}</span>\
      <span class="icon-bookslibrary"></span>)
      end

      def call_number_link
        cn = ''
        unless call_number.nil?
          children = call_number_span
          cn_browse_link = link_to(children.html_safe,
                                   "/browse/call_numbers?q=#{CGI.escape(call_number)}",
                                   class: 'browse-cn',
                                   'data-original-title' => "Browse: #{call_number}")
          cn = "#{holding['call_number']} #{cn_browse_link}"
        end
        content_tag(:td, cn.html_safe, class: 'holding-call-number')
      end

      def holding_location_repository
        children = content_tag(:span,
                               'On-site access',
                               class: 'availability-icon badge bg-success')
        content_tag(:td, children.html_safe)
      end

      # Generate the links for a given holding
      def request_placeholder
        view_base = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
        link = request_link_component.render_in(view_base)
        location_services_block(link)
      end

      def request_link_component
        holding_object = Requests::Holding.new(mfhd_id: holding_id, holding_data: holding)
        if holding_id == 'thesis' || numismatics?
          AeonRequestButtonComponent.new(document: adapter.document, holding: holding_object.to_h, url_class: Requests::NonAlmaAeonUrl)
        elsif holding['items'] && holding['items'].length > 1
          RequestButtonComponent.new(doc_id:, holding_id:, location: location_rules)
        elsif aeon_location?
          AeonRequestButtonComponent.new(document: adapter.document, holding: holding_object.to_h)
        elsif scsb_location?
          RequestButtonComponent.new(doc_id:, location: location_rules, holding:)
        elsif temporary_holding_id?
          holding_identifier = temporary_location_holding_id_first
          RequestButtonComponent.new(doc_id:, holding_id: holding_identifier, location: location_rules)
        else
          RequestButtonComponent.new(doc_id:, holding_id:, location: location_rules)
        end
      end

      def numismatics?
        holding_id == 'numismatics'
      end

      # Generate the location services markup for a holding
      # @param adapter [HoldingRequestsAdapter] adapter for the Solr Document and Bibdata
      # @param holding_id [String]
      # @param link [String] link markup
      # @return [String] block markup
      def location_services_block(link)
        content_tag(:td, link,
                    class: "location-services #{show_request}",
                    data: {
                      open: open_location?,
                      requestable: requestable_location?,
                      aeon: aeon_location?,
                      holding_id:
                    })
      end

      # Generate the CSS class for holding based upon its location and ID
      # @param adapter [HoldingRequestsAdapter] adapter for the Solr Document and Bibdata
      # @param location [Hash] location information
      # @param holding_id [String]
      # @return [String] the CSS class
      def show_request
        if (requestable? && !thesis?) || numismatics?
          'service-always-requestable'
        else
          'service-conditional'
        end
      end

      def requestable?
        !adapter.alma_holding?(holding_id) || aeon_location? || scsb_location?
      end

      def thesis?
        holding_id == 'thesis' && adapter.pub_date > 2012
      end

      def open_location?
        location_rules.nil? ? false : location_rules[:open]
      end

      def requestable_location?
        return false if adapter.sc_location_with_suppressed_button?(holding)
        if location_rules.nil?
          false
        elsif adapter.unavailable_holding?(holding)
          false
        else
          location_rules[:requestable]
        end
      end

      def aeon_location?
        location_rules.nil? ? false : location_rules[:aeon_location]
      end

      def build_holding_notes
        holding_notes = ''

        holding_notes << shelving_titles_list if adapter.shelving_title?(holding)
        holding_notes << location_notes_list if adapter.location_note?(holding)
        holding_notes << location_has_list if adapter.location_has?(holding)
        holding_notes << multi_item_availability
        holding_notes << supplements_list if adapter.supplements?(holding)
        holding_notes << indexes_list if adapter.indexes?(holding)
        holding_notes << journal_issues_list if adapter.journal?

        holding_details(holding_notes) unless holding_notes.empty?
      end

      def multi_item_availability
        content_tag(:ul, '',
                    class: 'item-status',
                    data: {
                      'record_id' => doc_id,
                      'holding_id' => holding_id
                    })
      end

      # Generate <div> container for holding details
      # @param children [String] the children for the holding details
      # @return [String] the markup
      def holding_details(children)
        content_tag(:td, children.html_safe, class: 'holding-details') unless children.empty?
      end

      # Generate <div> container for a holding block
      # @param children [String] the children for the holding block
      # @return [String] the markup
      def holding_block(children)
        content_tag(:tr, children.html_safe, class: 'holding-block') unless children.empty?
      end

      def holding_location_default(doc_id, temp_location_code)
        children = content_tag(:span, '', class: 'availability-icon')

        data = {
          'availability_record' => true,
          'record_id' => doc_id,
          'holding_id' => holding_id,
          aeon: aeon_location?
        }

        data['temp_location_code'] = temp_location_code unless temp_location_code.nil?

        content_tag(:td,
                    children.html_safe,
                    class: 'holding-status',
                    data:)
      end

      def scsb_location?
        location_rules.nil? ? false : /^scsb.+/ =~ location_rules['code']
      end

      # Example of a temporary holding, in this case holding_id is : firestone$res3hr
      # {\"firestone$res3hr\":{\"location_code\":\"firestone$res3hr\",
      # \"current_location\":\"Circulation Desk (3 Hour Reserve)\",\"current_library\":\"Firestone Library\",
      # \"call_number\":\"HT1077 .M87\",\"call_number_browse\":\"HT1077 .M87\",
      # \"items\":[{\"holding_id\":\"22740601020006421\",\"id\":\"23740600990006421\",
      # \"status_at_load\":\"1\",\"barcode\":\"32101005621469\",\"copy_number\":\"1\"}]}}
      def temporary_holding_id?
        /[a-zA-Z]\$[a-zA-Z]/.match?(holding_id)
      end

      def location_has_list
        children = "#{holding_label('Location has')} #{listify_array(holding['location_has'])}"
        content_tag(:ul, children.html_safe, class: 'location-has')
      end

      def holding_label(label)
        content_tag(:li, label, class: 'holding-label')
      end

      def listify_array(arr)
        arr = arr.map do |e|
          content_tag(:li, e)
        end
        arr.join
      end

      def journal_issues_list
        content_tag(:ul, '',
                    class: 'journal-current-issues',
                    data: { journal: true, holding_id: })
      end

      def indexes_list
        children = "#{holding_label('Indexes')} #{listify_array(holding['indexes'])}"
        content_tag(:ul, children.html_safe, class: 'holding-indexes')
      end

      def holding_location_scsb_span
        content_tag(:span, '',
                    class: 'availability-icon badge')
      end

      def holding_location_scsb
        content_tag(:td, holding_location_scsb_span.html_safe,
                    class: 'holding-status',
                    data: {
                      'availability_record' => true,
                      'record_id' => doc_id,
                      'holding_id' => holding_id,
                      'scsb-barcode' => holding['items'].first['barcode'],
                      'aeon' => scsb_supervised_items?
                    })
      end

      def scsb_supervised_items?
        if holding.key? 'items'
          restricted_items = holding['items'].select do |item|
            item['use_statement'] == 'Supervised Use'
          end
          restricted_items.count == holding['items'].count
        else
          false
        end
      end

        # When it is a temporary location and is requestable, use the first holding_id of this temporary location items.
  def temporary_location_holding_id_first
    holding["items"][0]["holding_id"]
  end

  def location_notes_list
    children = "#{holding_label('Location note')} #{listify_array(holding['location_note'])}"
    content_tag(:ul, children.html_safe, class: 'location-note')
  end
end
