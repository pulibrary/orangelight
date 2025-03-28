# frozen_string_literal: false

class PhysicalHoldingsMarkupBuilder < HoldingRequestsBuilder
  include ApplicationHelper

  # Generate <span> markup used in links for browsing by call numbers
  # @return [String] the markup
  def call_number_span
    %(<span class="link-text">#{I18n.t('blacklight.holdings.browse')}</span>\
      <span class="icon-bookslibrary"></span>)
  end

  ##
  # Add call number link
  # @param [Hash] holding
  # @param [String] cn_value - a call number
  def call_number_link(holding, cn_value)
    cn = ''
    unless cn_value.nil?
      children = call_number_span
      cn_browse_link = link_to(children.html_safe,
                               "/browse/call_numbers?q=#{CGI.escape(cn_value)}",
                               class: 'browse-cn',
                               'data-original-title' => "Browse: #{cn_value}")
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

  def holding_location_scsb_span
    markup = content_tag(:span, '',
                         class: 'availability-icon badge')
    markup
  end

  def holding_location_scsb(holding, doc_id, holding_id)
    content_tag(:td, holding_location_scsb_span.html_safe,
                class: 'holding-status',
                data: {
                  'availability_record' => true,
                  'record_id' => doc_id,
                  'holding_id' => holding_id,
                  'scsb-barcode' => holding['items'].first['barcode'],
                  'aeon' => scsb_supervised_items?(holding)
                })
  end

  def holding_location_default(doc_id, holding_id, location_rules, temp_location_code)
    children = content_tag(:span, '', class: 'availability-icon')

    data = {
      'availability_record' => true,
      'record_id' => doc_id,
      'holding_id' => holding_id,
      aeon: self.class.aeon_location?(location_rules)
    }

    data['temp_location_code'] = temp_location_code unless temp_location_code.nil?

    content_tag(:td,
                 children.html_safe,
                 class: 'holding-status',
                 data:)
  end

  # Holding record with "dspace": false
  def holding_location_unavailable
    children = content_tag(:span,
                           'Unavailable',
                           class: 'availability-icon badge bg-danger')
    content_tag(:td, children.html_safe, class: 'holding-status')
  end

  def self.holding_label(label)
    content_tag(:li, label, class: 'holding-label')
  end

  def self.shelving_titles_list(holding)
    children = "#{holding_label('Shelving title')} #{listify_array(holding['shelving_title'])}"
    content_tag(:ul, children.html_safe, class: 'shelving-title')
  end

  def self.location_notes_list(holding)
    children = "#{holding_label('Location note')} #{listify_array(holding['location_note'])}"
    content_tag(:ul, children.html_safe, class: 'location-note')
  end

  def self.location_has_list(holding)
    children = "#{holding_label('Location has')} #{listify_array(holding['location_has'])}"
    content_tag(:ul, children.html_safe, class: 'location-has')
  end

  def self.multi_item_availability(doc_id, holding_id)
    content_tag(:ul, '',
                class: 'item-status',
                data: {
                  'record_id' => doc_id,
                  'holding_id' => holding_id
                })
  end

  def self.supplements_list(holding)
    children = "#{holding_label('Supplements')} #{listify_array(holding['supplements'])}"
    content_tag(:ul, children.html_safe, class: 'holding-supplements')
  end

  def self.indexes_list(holding)
    children = "#{holding_label('Indexes')} #{listify_array(holding['indexes'])}"
    content_tag(:ul, children.html_safe, class: 'holding-indexes')
  end

  def self.journal_issues_list(holding_id)
    content_tag(:ul, '',
                class: 'journal-current-issues',
                data: { journal: true, holding_id: })
  end

  def self.scsb_use_label(restriction)
    "#{restriction} Only"
  end

  # Generate the markup for record restrictions
  # @param holding [Hash] the restrictions for all holdings
  # @return [String] the markup
  def self.restrictions_markup(restrictions)
    restricted_items = restrictions.map do |value|
      content_tag(:td, scsb_use_label(value))
    end
    if restricted_items.length > 1
      list = restricted_items.map { |value| content_tag(:li, value) }
      content_tag(:ul, list.join.html_safe, class: 'restrictions-list item-list')
    else
      restricted_items.join.html_safe
    end
  end

  def self.open_location?(location)
    location.nil? ? false : location[:open]
  end

  def self.requestable_location?(location, adapter, holding)
    return false if adapter.sc_location_with_suppressed_button?(holding)
    if location.nil?
      false
    elsif adapter.unavailable_holding?(holding)
      false
    else
      location[:requestable]
    end
  end

  def self.aeon_location?(location)
    location.nil? ? false : location[:aeon_location]
  end

  delegate :aeon_location?, to: :class

  def self.scsb_location?(location)
    location.nil? ? false : /^scsb.+/ =~ location['code']
  end

  def self.requestable?(adapter, holding_id, location)
    !adapter.alma_holding?(holding_id) || aeon_location?(location) || scsb_location?(location)
  end

  def self.thesis?(adapter, holding_id)
    holding_id == 'thesis' && adapter.pub_date > 2012
  end

  def self.numismatics?(holding_id)
    holding_id == 'numismatics'
  end

  # Generate the CSS class for holding based upon its location and ID
  # @param adapter [HoldingRequestsAdapter] adapter for the Solr Document and Bibdata
  # @param location [Hash] location information
  # @param holding_id [String]
  # @return [String] the CSS class
  def self.show_request(adapter, location, holding_id)
    if requestable?(adapter, holding_id, location) && !thesis?(adapter, holding_id) || numismatics?(holding_id)
      'service-always-requestable'
    else
      'service-conditional'
    end
  end

  # Generate the location services markup for a holding
  # @param adapter [HoldingRequestsAdapter] adapter for the Solr Document and Bibdata
  # @param holding_id [String]
  # @param location_rules [Hash]
  # @param link [String] link markup
  # @return [String] block markup
  def self.location_services_block(adapter, holding_id, location_rules, link, holding)
    content_tag(:td, link,
                class: "location-services #{show_request(adapter, location_rules, holding_id)}",
                data: {
                  open: open_location?(location_rules),
                  requestable: requestable_location?(location_rules, adapter, holding),
                  aeon: aeon_location?(location_rules),
                  holding_id:
                })
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

  delegate :scsb_supervised_items?, to: :class

  ##
  def self.listify_array(arr)
    arr = arr.map do |e|
      content_tag(:li, e)
    end
    arr.join
  end

  def doc_id(holding)
    holding.dig("mms_id") || adapter.doc_id
  end

  # Example of a temporary holding, in this case holding_id is : firestone$res3hr
  # {\"firestone$res3hr\":{\"location_code\":\"firestone$res3hr\",
  # \"current_location\":\"Circulation Desk (3 Hour Reserve)\",\"current_library\":\"Firestone Library\",
  # \"call_number\":\"HT1077 .M87\",\"call_number_browse\":\"HT1077 .M87\",
  # \"items\":[{\"holding_id\":\"22740601020006421\",\"id\":\"23740600990006421\",
  # \"status_at_load\":\"1\",\"barcode\":\"32101005621469\",\"copy_number\":\"1\"}]}}
  def self.temporary_holding_id?(holding_id)
    /[a-zA-Z]\$[a-zA-Z]/.match?(holding_id)
  end

  # When it is a temporary location and is requestable, use the first holding_id of this temporary location items.
  def self.temporary_location_holding_id_first(holding)
    holding["items"][0]["holding_id"]
  end

  # Generate the links for a given holding
  # TODO: Come back and remove class method calls
  def request_placeholder(adapter, holding_id, location_rules, holding)
    doc_id = doc_id(holding)
    view_base = ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil)
    link = request_link_component(adapter:, holding_id:, doc_id:, holding:, location_rules:).render_in(view_base)
    markup = self.class.location_services_block(adapter, holding_id, location_rules, link, holding)
    markup
  end

  def request_link_component(adapter:, holding_id:, doc_id:, holding:, location_rules:)
    holding_object = Requests::Holding.new(mfhd_id: holding_id, holding_data: holding)
    if holding_id == 'thesis' || self.class.numismatics?(holding_id)
      AeonRequestButtonComponent.new(document: adapter.document, holding: holding_object.to_h, url_class: Requests::NonAlmaAeonUrl)
    elsif holding['items'] && holding['items'].length > 1
      RequestButtonComponent.new(doc_id:, holding_id:, location: location_rules)
    elsif aeon_location?(location_rules)
      AeonRequestButtonComponent.new(document: adapter.document, holding: holding_object.to_h)
    elsif self.class.scsb_location?(location_rules)
      RequestButtonComponent.new(doc_id:, location: location_rules, holding:)
    elsif self.class.temporary_holding_id?(holding_id)
      holding_identifier = self.class.temporary_location_holding_id_first(holding)
      RequestButtonComponent.new(doc_id:, holding_id: holding_identifier, location: location_rules)
    else
      RequestButtonComponent.new(doc_id:, holding_id:, location: location_rules)
    end
  end

  attr_reader :adapter
  delegate :content_tag, :link_to, to: :class

  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  def initialize(adapter)
    @adapter = adapter
  end

  # Builds the markup for online and physical holdings for a given record
  # @return [String] the markup for the online and physical holdings
  def build
    physical_holdings_block
  end

  # Generate a <span> element for a holding location
  # @param location [String] the location value
  # @param holding_id [String] the ID for the holding
  # @return [String] <span> markup
  def holding_location_span(location, holding_id)
    content_tag(:span, location,
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
  def locate_link(location, call_number, library, holding)
    locator = StackmapLocationFactory.new(resolver_service: ::StackmapService::Url)
    return '' if locator.exclude?(call_number:, library:)

    markup = ''
    markup = stackmap_span_markup(location, library, holding) if find_it_location?(location)
    ' ' + markup
  end

  def stackmap_span_markup(location, library, holding)
    content_tag(:span, '',
                data: {
                  'map-location': location.to_s,
                  'location-library': library,
                  'location-name': holding['location']
                })
  end

  # Generate the links for a specific holding
  # @param holding [Hash] the information for the holding
  # @param location [Hash] the location information for the holding
  # @param holding_id [String] the ID for the holding
  # @param call_number [String] the call number
  # @param [String] the markup
  def holding_location_container(holding, location, holding_id, call_number)
    markup = holding_location_span(location, holding_id)
    link_markup = locate_link(holding['location_code'], call_number, holding['library'], holding)
    markup << link_markup.html_safe
    markup
  end

  # Generate the markup block for a specific holding
  # @param holding [Hash] the information for the holding
  # @param location [Hash] the location information for the holding
  # @param holding_id [String] the ID for the holding
  # @param call_number [String] the call number
  # @param [String] the markup
  def holding_location(holding, location, holding_id, call_number)
    location = holding_location_container(holding, location, holding_id, call_number)
    markup = ''
    markup << content_tag(:td, location.html_safe,
                          class: 'library-location',
                          data: { holding_id: })
    markup
  end

  private

    # Generate the markup for a physical holding record
    # @param holding [Hash] holding information from a Solr Document
    # @param holding_id [String] the ID for the holding record
    # @return [String] the markup
    def process_physical_holding(holding, holding_id)
      markup = ''
      doc_id = doc_id(holding)
      temp_location_code = @adapter.temp_location_code(holding)

      location_rules = @adapter.holding_location_rules(holding)
      cn_value = @adapter.call_number(holding)

      holding_loc = @adapter.holding_location_label(holding)
      if holding_loc.present?
        markup = holding_location(
          holding,
          holding_loc,
          holding_id,
          cn_value
        )
      end
      markup << call_number_link(holding, cn_value)
      markup << if @adapter.repository_holding?(holding)
                  holding_location_repository
                elsif @adapter.scsb_holding?(holding) && !@adapter.empty_holding?(holding)
                  holding_location_scsb(holding, doc_id, holding_id)
                elsif @adapter.unavailable_holding?(holding)
                  holding_location_unavailable
                else
                  holding_location_default(doc_id,
                                           holding_id,
                                           location_rules,
                                           temp_location_code)
                end

      request_placeholder_markup = request_placeholder(@adapter, holding_id, location_rules, holding)
      markup << request_placeholder_markup.html_safe

      markup << build_holding_notes(holding, holding_id)

      markup = self.class.holding_block(markup) unless markup.empty?
      markup
    end

    def build_holding_notes(holding, holding_id)
      holding_notes = ''

      holding_notes << self.class.shelving_titles_list(holding) if @adapter.shelving_title?(holding)
      holding_notes << self.class.location_notes_list(holding) if @adapter.location_note?(holding)
      holding_notes << self.class.location_has_list(holding) if @adapter.location_has?(holding)
      holding_notes << self.class.multi_item_availability(doc_id(holding), holding_id)
      holding_notes << self.class.supplements_list(holding) if @adapter.supplements?(holding)
      holding_notes << self.class.indexes_list(holding) if @adapter.indexes?(holding)
      holding_notes << self.class.journal_issues_list(holding_id) if @adapter.journal?

      self.class.holding_details(holding_notes) unless holding_notes.empty?
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
      markup = self.class.content_tag(:tbody, children.html_safe) unless children.empty?
      markup
    end
end
