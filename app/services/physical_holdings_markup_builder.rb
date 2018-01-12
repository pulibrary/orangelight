# frozen_string_literal: false

class PhysicalHoldingsMarkupBuilder < HoldingRequestsBuilder
  # Generate a <span> element for a holding location
  # @param location [String] the location value
  # @param holding_id [String] the ID for the holding
  # @return [String] <span> markup
  def self.holding_location_span(location, holding_id)
    content_tag(:span, location,
                class: 'location-text',
                data: { location: true, holding_id: holding_id })
  end

  # Generate the link for a specific holding
  # @param adapter [HoldingRequestsAdapter] adapter for the the Solr Document and Bibdata
  # @param holding [Hash] the information for the holding
  # @param location [Hash] the location information for the holding
  # @param holding_id [String] the ID for the holding
  # @param call_number [String] the call number
  # @param library [String] the library in which the holding resides
  # @param [String] the markup
  def self.locate_link(adapter, location, call_number, library)
    locator = StackmapLocationFactory.new(resolver_service: ::StackmapService::Url)
    resolved = locator.resolve(
      location: location,
      document: adapter.document,
      call_number: call_number,
      library: library
    )
    return '' if resolved.nil?

    link = resolved.url
    return '' if link.nil?

    child = %(<span class="link-text">#{I18n.t('blacklight.holdings.stackmap')}</span>\
      <span class="glyphicon glyphicon-map-marker"></span>)
    markup = link_to(child.html_safe, link,
                     :target => '_blank',
                     title: I18n.t('blacklight.holdings.stackmap'),
                     class: 'find-it',
                     'data-map-location' => location.to_s,
                     'data-toggle' => 'tooltip')
    ' ' + markup
  end

  # Generate the links for a specific holding
  # @param adapter [HoldingRequestsAdapter] adapter for the the Solr Document and Bibdata
  # @param holding [Hash] the information for the holding
  # @param location [Hash] the location information for the holding
  # @param holding_id [String] the ID for the holding
  # @param call_number [String] the call number
  # @param [String] the markup
  def self.holding_location_container(adapter, holding, location, holding_id, call_number)
    markup = holding_location_span(location, holding_id)
    link_markup = locate_link(adapter, holding['location_code'], call_number, holding['library'])
    markup << link_markup.html_safe
    markup
  end

  # Generate the markup block for a specific holding
  # @param adapter [HoldingRequestsAdapter] adapter for the the Solr Document and Bibdata
  # @param holding [Hash] the information for the holding
  # @param location [Hash] the location information for the holding
  # @param holding_id [String] the ID for the holding
  # @param call_number [String] the call number
  # @param [String] the markup
  def self.holding_location(adapter, holding, location, holding_id, call_number)
    location = holding_location_container(adapter, holding, location, holding_id, call_number)
    markup = ''
    markup << content_tag(:h3, location.html_safe,
                          class: 'library-location',
                          data: { holding_id: holding_id })
    markup
  end

  # Generate <span> markup used in links for browsing by call numbers
  # @return [String] the markup
  def self.call_number_span
    %(<span class="link-text">#{I18n.t('blacklight.holdings.browse')}</span>\
      <span class="icon-bookslibrary"></span>)
  end

  def self.call_number_link(holding, cn_value)
    markup = ''
    unless cn_value.nil?
      children = call_number_span
      cn_browse_link = link_to(children.html_safe,
                               "/browse/call_numbers?q=#{CGI.escape(cn_value)}",
                               class: 'browse-cn',
                               title: "Browse: #{cn_value}",
                               'data-toggle' => 'tooltip',
                               'data-original-title' => "Browse: #{cn_value}")
      cn = "#{holding['call_number']} #{cn_browse_link}"
      markup << content_tag(:div, cn.html_safe, class: 'holding-call-number')
    end
    markup
  end

  def self.holding_location_repository
    content_tag(:span, 'On-site access',
                class: 'availability-icon label label-warning',
                title: 'Availability: On-site by request',
                'data-toggle' => 'tooltip')
  end

  def self.holding_location_scsb_span
    markup = content_tag(:span, '',
                         title: '',
                         class: 'availability-icon label',
                         data: { toggle: 'tooltip' })
    markup
  end

  def self.holding_location_scsb(holding, bib_id, holding_id)
    content_tag(:div, holding_location_scsb_span.html_safe,
                class: 'holding-status',
                data: {
                  'availability_record' => true,
                  'record_id' => bib_id,
                  'holding_id' => holding_id,
                  'scsb-barcode' => holding['items'].first['barcode'],
                  'aeon' => scsb_supervised_items?(holding)
                })
  end

  # For when a holding record has a value for the "dspace" key, but it is set to false
  def self.holding_location_default(bib_id, holding_id, location_rules)
    children = content_tag(:div, '', class: 'availability-icon')
    content_tag(:div,
                children.html_safe,
                class: 'holding-status',
                data: {
                  'availability_record' => true,
                  'record_id' => bib_id,
                  'holding_id' => holding_id,
                  aeon: aeon_location?(location_rules)
                })
  end

  def self.holding_location_unavailable
    content_tag(:span, 'Unavailable', class: 'availability-icon label label-danger',
                                      title: 'Availability: Embargoed', 'data-toggle' => 'tooltip')
  end

  def self.holding_label(label)
    content_tag(:div, label, class: 'holding-label')
  end

  def self.shelving_titles_list(holding)
    children = "#{holding_label('Shelving title:')} #{listify_array(holding['shelving_title'])}"
    content_tag(:ul, children.html_safe, class: 'shelving-title')
  end

  def self.location_notes_list(holding)
    children = "#{holding_label('Location note:')} #{listify_array(holding['location_note'])}"
    content_tag(:ul, children.html_safe, class: 'location-note')
  end

  def self.location_has_list(holding)
    children = "#{holding_label('Location has:')} #{listify_array(holding['location_has'])}"
    content_tag(:ul, children.html_safe, class: 'location-has')
  end

  def self.journal_issues_list(holding_id)
    content_tag(:ul, '',
                class: 'journal-current-issues',
                data: { journal: true, holding_id: holding_id })
  end

  def self.scsb_use_label(restriction)
    "#{restriction} Only"
  end

  def self.scsb_use_toolip(restriction)
    if restriction == 'In Library Use'
      I18n.t('blacklight.scsb.in_library_use')
    else
      I18n.t('blacklight.scsb.supervised_use')
    end
  end

  # Generate the markup for a list item <li> containing a ReCAP holding
  # @param item [Hash] the values for a given ReCAP holding
  # @return [String] the markup
  def self.scsb_list_item(item, children)
    content_tag(:li, children.html_safe,
                title: scsb_use_toolip(item['use_statement']),
                'data-toggle' => 'tooltip')
  end

  # Generate the markup for an unordered list <ol> containing ReCAP holding
  # @param holding [Hash] the values for a given ReCAP holding
  # @return [String] the markup
  def self.scsb_list(holding)
    restricted_items = holding['items'].map do |values|
      item_markup = ''
      if values['use_statement'].present?
        child = content_tag(:span,
                            scsb_use_label(values['use_statement']),
                            class: 'icon-warning icon-request-reading-room')
        item_markup = scsb_list_item(values, child)
      end
      item_markup
    end

    restricted_items.compact!

    return '' if restricted_items.empty?

    restricted_items.uniq!
    children = "#{holding_label('Use Restrictions:')} #{restricted_items.join}"
    content_tag(:ul, children.html_safe, class: 'item-list')
  end

  def self.open_location?(location)
    location.nil? ? false : location[:open]
  end

  def self.requestable_location?(location)
    location.nil? ? false : location[:requestable]
  end

  def self.aeon_location?(location)
    location.nil? ? false : location[:aeon_location]
  end

  def self.scsb_location?(location)
    /^scsb.+/ =~ location['code']
  end

  def self.requestable?(adapter, holding_id, location)
    !adapter.voyager_holding?(holding_id) || aeon_location?(location) || scsb_location?(location)
  end

  # Generate the CSS class for holding based upon its location and ID
  # @param adapter [HoldingRequestsAdapter] adapter for the Solr Document and Bibdata
  # @param location [Hash] location information
  # @param holding_id [String]
  # @return [String] the CSS class
  def self.show_request(adapter, location, holding_id)
    if requestable?(adapter, holding_id, location)
      'service-always-requestable'
    else
      'service-conditional'
    end
  end

  # Generate the location services markup for a holding
  # @param adapter [HoldingRequestsAdapter] adapter for the Solr Document and Bibdata
  # @param holding_id [String]
  # @param location_rules [Hash]
  # @param link [String]
  # @return [String] block markup
  def self.location_services_block(adapter, holding_id, location_rules, link)
    content_tag(:div, link,
                class: "location-services #{show_request(adapter, location_rules, holding_id)}",
                data: {
                  open: open_location?(location_rules),
                  requestable: requestable_location?(location_rules),
                  aeon: aeon_location?(location_rules),
                  holding_id: holding_id
                })
  end

  # Generate a request label based upon the holding location
  # @param location_rules [Hash] the location for the holding
  # @return [String] the label
  def self.request_label(location_rules)
    if aeon_location?(location_rules)
      'Reading Room Request'
    else
      'Request'
    end
  end

  # Generate a request tooltip based upon the holding location
  # @param location_rules [Hash] the location for the holding
  # @return [String] the label
  def self.request_tooltip(location_rules)
    if aeon_location?(location_rules)
      'Request to view in Reading Room'
    else
      'View Options to Request copies from this Location'
    end
  end

  def self.scsb_supervised_request_link
    link_to('Reading Room Request',
            "/requests/#{doc_id}?source=pulsearch",
            title: 'Request to view in Reading Room',
            class: 'request btn btn-xs btn-primary',
            data: { toggle: 'tooltip' })
  end

  def self.scsb_request_link
    link_to(request_label(location_rules),
            "/requests/#{doc_id}?source=pulsearch",
            title: request_tooltip(location_rules),
            class: 'request btn btn-xs btn-primary',
            data: { toggle: 'tooltip' })
  end

  def self.ils_request_link
    link_to(request_label(location_rules),
            "/requests/#{doc_id}?mfhd=#{holding_id}&source=pulsearch",
            title: request_tooltip(location_rules),
            class: 'request btn btn-xs btn-primary',
            data: { toggle: 'tooltip' })
  end

  def self.request_link
    link_to('Reading Room Request',
            "/requests/#{doc_id}?mfhd=#{holding_id}&source=pulsearch",
            title: 'Request to view in Reading Room',
            class: 'request btn btn-xs btn-primary',
            data: { toggle: 'tooltip' })
  end

  def self.scsb_supervised_items?(holding)
    if holding.key? 'items'
      restricted_items = holding['items'].select do |item|
        item['use_statement'] == 'Supervised Use'
      end
      restricted_items.count == holding['items'].count
    else
      false
    end
  end

  ##
  def self.listify_array(arr)
    arr = arr.map do |e|
      content_tag(:li, e)
    end
    arr.join
  end

  # Generate the links for a given holding
  def self.request_placeholder(adapter, holding_id, location_rules, holding)
    doc_id = adapter.doc_id
    link = if /^scsb.+/.match? location_rules['code']
             if scsb_supervised_items?(holding)
               link_to('Reading Room Request',
                       "/requests/#{doc_id}?source=pulsearch",
                       title: 'Request to view in Reading Room',
                       class: 'request btn btn-xs btn-primary',
                       data: { toggle: 'tooltip' })
             else
               link_to(request_label(location_rules),
                       "/requests/#{doc_id}?source=pulsearch",
                       title: request_tooltip(location_rules),
                       class: 'request btn btn-xs btn-primary',
                       data: { toggle: 'tooltip' })
             end
           elsif !adapter.voyager_holding?(holding_id)
             link_to('Reading Room Request',
                     "/requests/#{doc_id}?mfhd=#{holding_id}&source=pulsearch",
                     title: 'Request to view in Reading Room',
                     class: 'request btn btn-xs btn-primary',
                     data: { toggle: 'tooltip' })
           else
             link_to(request_label(location_rules),
                     "/requests/#{doc_id}?mfhd=#{holding_id}&source=pulsearch",
                     title: request_tooltip(location_rules),
                     class: 'request btn btn-xs btn-primary',
                     data: { toggle: 'tooltip' })
           end
    markup = location_services_block(adapter, holding_id, location_rules, link)
    markup
  end

  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  def initialize(adapter)
    @adapter = adapter
  end

  # Builds the markup for online and physical holdings for a given record
  # @return [Array<String>] the markup for the online and physical holdings
  def build
    physical_holdings_block
  end

  private

    # Generate the markup for a physical holding record
    # @param holding [Hash] holding information from a Solr Document
    # @param holding_id [String] the ID for the holding record
    # @return [String] the markup
    def process_physical_holding(holding, holding_id)
      markup = ''

      bib_id = @adapter.doc_id
      location_rules = @adapter.holding_location_rules(holding)
      cn_value = @adapter.call_number(holding)
      holding_loc = @adapter.holding_location_label(holding)
      if holding_loc.present?
        markup = self.class.holding_location(@adapter,
                                             holding,
                                             holding_loc,
                                             holding_id,
                                             cn_value)
      end
      markup << self.class.call_number_link(holding, cn_value) unless cn_value.nil?
      markup << if @adapter.repository_holding?(holding)
                  self.class.holding_location_repository
                elsif @adapter.scsb_holding?(holding) && !@adapter.empty_holding?(holding)
                  self.class.holding_location_scsb(holding, bib_id, holding_id)
                elsif @adapter.unavailable_holding?(holding)
                  self.class.holding_location_unavailable
                else
                  self.class.holding_location_default(bib_id,
                                                      holding_id,
                                                      location_rules)
                end

      markup << self.class.shelving_titles_list(holding) if @adapter.shelving_title?(holding)
      markup << self.class.location_notes_list(holding) if @adapter.location_note?(holding)
      markup << self.class.location_has_list(holding) if @adapter.location_has?(holding)
      markup << self.class.journal_issues_list(holding_id) if @adapter.journal?

      if @adapter.scsb_holding?(holding) && !@adapter.empty_holding?(holding)
        markup << self.class.scsb_list(holding)
      end

      unless holding_id == 'thesis' && @adapter.pub_date > 2012
        request_placeholder_markup = \
          self.class.request_placeholder(@adapter, holding_id, location_rules, holding)
        markup << request_placeholder_markup.html_safe
      end
      markup = self.class.holding_block(markup) unless markup.empty?
      markup
    end

    # Generate the markup for physical holdings
    # @return [String] the markup
    def physical_holdings
      markup = ''
      @adapter.sorted_physical_holdings.each do |holding_id, holding|
        markup << process_physical_holding(holding, holding_id)
      end
      markup
    end

    # Generate the markup block for physical holdings
    # @return [String] the markup
    def physical_holdings_block
      markup = ''
      children = physical_holdings
      markup = self.class.content_tag(:div, children.html_safe) unless children.empty?
      markup
    end
end
