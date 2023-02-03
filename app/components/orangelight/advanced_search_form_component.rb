# frozen_string_literal: true

class Orangelight::AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent
  def initialize_search_filter_controls
    fields = blacklight_config.facet_fields.select { |_k, v| v.include_in_advanced_search || v.include_in_advanced_search.nil? }

    fields.each do |_k, config|
      config.advanced_search_component = Orangelight::FacetFieldCheckboxesComponent
      display_facet = @response.aggregations[config.field]
      search_filter_control(config:, display_facet:)
    end
  end
end
