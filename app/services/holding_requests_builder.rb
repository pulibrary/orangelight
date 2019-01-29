# frozen_string_literal: true

class HoldingRequestsBuilder
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::UrlHelper

  # Generate <div> container for a holding block
  # @param children [String] the children for the holding block
  # @return [String] the markup
  def self.holding_block(children)
    content_tag(:tr, children.html_safe, class: 'holding-block') unless children.empty?
  end

  # Generate <div> container for holding details
  # @param children [String] the children for the holding details
  # @return [String] the markup
  def self.holding_details(children)
    content_tag(:td, children.html_safe, class: 'holding-details') unless children.empty?
  end

  # Generate <div> container for missing item holdings
  # @return [String] the markup
  def self.missing_holdings
    holding_block(I18n.t('blacklight.holdings.missing'))
  end

  # Constructor
  # @param adapter [HoldingRequestsAdapter] adapter for the SolrDocument and Bibdata API
  # @param online_markup_builder [Class] the builder class for online holdings blocks
  # @param physical_markup_builder [Class] the builder class for physical holdings blocks
  def initialize(adapter:, online_markup_builder:, physical_markup_builder:)
    @adapter = adapter
    @online_markup_builder = online_markup_builder
    @physical_markup_builder = physical_markup_builder
  end

  # Builds the markup for online and physical holdings for a given record
  # @return [Array<String>] the markup for the online and physical holdings
  def build
    online_builder = @online_markup_builder.new(@adapter)
    online_markup = online_builder.build

    physical_builder = @physical_markup_builder.new(@adapter)
    physical_markup = physical_builder.build

    physical_markup = self.class.missing_holdings if physical_markup.blank? && online_markup.blank?

    [online_markup, physical_markup]
  end
end
