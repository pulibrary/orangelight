# frozen_string_literal: true

class NumismaticsSearchFormComponent < Blacklight::AdvancedSearchFormComponent
  def initialize_search_filter_controls
    fields = ['issue_object_type_s', 'issue_denomination_s',
              'issue_metal_s', 'issue_city_s', 'issue_state_s',
              'issue_region_s', 'issue_ruler_s',
              'issue_artists_s', 'find_place_s'].map do |field_name|
      blacklight_config.facet_fields[field_name]
    end.compact

    fields.each do |config|
      config.advanced_search_component = Orangelight::FacetFieldCheckboxesComponent
      display_facet = @response.aggregations[config.field]
      search_filter_control(config:, display_facet:)
    end
  end

  def pub_date_field
    blacklight_config.facet_fields['pub_date_start_sort']
  end

  def pub_date_presenter
    view_context.facet_field_presenter(pub_date_field, {})
  end

  def sort_fields_select
    options = sort_fields.values.map { |field_config| [helpers.sort_field_label(field_config.key), field_config.key] }
    return unless options.any?

    select_tag(:sort, options_for_select(options, params[:sort]), class: "sort-select", aria: { labelledby: 'advanced-search-sort-label' })
  end
end
