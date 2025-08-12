# frozen_string_literal: true

# This builder is responsible for constructing all markup for physical holdings
# on the catalog show page
class PhysicalHoldingsMarkupBuilder < HoldingRequestsBuilder
  include ApplicationHelper

  attr_reader :adapter
  delegate :content_tag, :link_to, to: :class

  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  # @param params [ActionController::Parameters]
  def initialize(adapter, params = ActionController::Parameters.new)
    @adapter = adapter
    @params = params.permit(:open_holdings)
  end

  # Builds the markup for online and physical holdings for a given record
  # @return [String] the markup for the physical holdings
  def build
    physical_holdings_block
  end

  private

    attr_reader :params

    # Generate the markup for physical holdings
    # @return [String] the markup
    def physical_holdings
      @adapter.grouped_physical_holdings.each_with_index.map do |group, index|
        render_component(Holdings::PhysicalHoldingGroupComponent.new(adapter:, group:, open: open_group?(index, group)))
      end.join
    end

    # Generate the markup block for physical holdings
    # @return [String] the markup
    def physical_holdings_block
      children = physical_holdings
      if children.empty?
        ''
      else
        self.class.content_tag(:tbody, children.html_safe)
      end
    end

    def render_component(component)
      view_context.render(component)
    end

    def view_context
      @view_context ||= ApplicationController.new.view_context
    end

    def open_group?(index, group)
      index.zero? || params[:open_holdings] == group.group_name
    end
end
