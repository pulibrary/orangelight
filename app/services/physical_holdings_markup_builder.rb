# frozen_string_literal: false

class PhysicalHoldingsMarkupBuilder < HoldingRequestsBuilder
  include ApplicationHelper

  def holding_location_repository
    children = content_tag(:span,
                           'Available',
                           class: 'availability-icon badge bg-success')
    content_tag(:td, children.html_safe)
  end

  # Holding record with "dspace": false
  def holding_location_unavailable
    children = content_tag(:span,
                           'Request',
                           class: 'availability-icon badge bg-danger')
    content_tag(:td, children.html_safe, class: 'holding-status')
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
      markup = render_component Holdings::HoldingLocationComponent.new(holding, holding_loc, holding_id, cn_value) if holding_loc.present?
      markup << render_component(Holdings::CallNumberLinkComponent.new(holding, cn_value))
      markup << if @adapter.repository_holding?(holding)
                  holding_location_repository
                elsif @adapter.scsb_holding?(holding) && !@adapter.empty_holding?(holding)
                  render_component Holdings::HoldingAvailabilityScsbComponent.new(holding, doc_id, holding_id)
                elsif @adapter.unavailable_holding?(holding)
                  holding_location_unavailable
                else
                  render_component Holdings::HoldingAvailabilityComponent.new(doc_id, holding_id, location_rules, temp_location_code)
                end

      request_placeholder_markup = request_placeholder(@adapter, holding_id, location_rules, holding)
      markup << request_placeholder_markup.html_safe

      markup << render_component(Holdings::HoldingNotesComponent.new(holding, holding_id, @adapter))

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
      markup = self.class.content_tag(:tbody, children.html_safe) unless children.empty?
      markup
    end

    def render_component(component)
      view_context.render(component)
    end

    def view_context
      @view_context ||= ApplicationController.new.view_context
    end
end
