# frozen_string_literal: false

class PhysicalHoldingsMarkupBuilder < HoldingRequestsBuilder
  include ApplicationHelper

  def holding_location_repository
    children = content_tag(:span,
                           'On-site access',
                           class: 'availability-icon badge bg-success')
    content_tag(:td, children.html_safe)
  end

  # Holding record with "dspace": false
  def holding_location_unavailable
    children = content_tag(:span,
                           'Unavailable',
                           class: 'availability-icon badge bg-danger')
    content_tag(:td, children.html_safe, class: 'holding-status')
  end

  def doc_id(holding)
    holding.dig("mms_id") || adapter.doc_id
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
      markup << render_component(Holdings::LocationServicesComponent.new(adapter, holding_id, location_rules, holding))
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
