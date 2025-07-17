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
