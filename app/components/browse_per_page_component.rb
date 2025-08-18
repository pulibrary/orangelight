# frozen_string_literal: true
# This component displays the page options on the browse screen
class BrowsePerPageComponent < Blacklight::Search::PerPageComponent
  attr_reader :search_state

  def render?
    true
  end

  def initialize(
    blacklight_config:,
    response:,
    search_state:,
    current_browse_per_page:
  )
    super(blacklight_config:, response:, search_state:)
    @current_browse_per_page = current_browse_per_page
  end

  def current_per_page
    @current_browse_per_page
  end

  def per_page_options_for_select
    [10, 25, 50, 100].map do |count|
      [t(:'blacklight.search.per_page.label', count: count).html_safe, count]
    end
  end

  def dropdown
    render(dropdown_class.new(
             param: :rpp,
             choices: per_page_options_for_select,
             id: 'per_page-dropdown',
             search_state: search_state,
             selected: current_per_page,
             interpolation: :count
           ))
  end
end
