# frozen_string_literal: true

class Orangelight::AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent
  def sort_fields_select
    options = sort_fields.values.map { |field_config| [helpers.sort_field_label(field_config.key), field_config.key] }
    return unless options.any?

    select_tag(:sort, options_for_select(options, params[:sort]), class: "sort-select", aria: { labelledby: 'advanced-search-sort-label' })
  end

  def initialize_search_filter_controls
    fields = blacklight_config.facet_fields.select { |_k, v| v.include_in_advanced_search || v.include_in_advanced_search.nil? }

    fields.each do |_k, config|
      config.advanced_search_component = Orangelight::FacetFieldCheckboxesComponent
      display_facet = @response.aggregations[config.field]
      with_search_filter_control(config:, display_facet:)
    end
  end

  def pub_date_field
    blacklight_config.facet_fields['pub_date_start_sort']
  end

  def pub_date_presenter
    view_context.facet_field_presenter(pub_date_field, {})
  end

  def initialize_search_field_controls
    search_fields.values.each.with_index do |field, index|
      with_search_field_control do
        fields_for_etc(index:, field:)
      end
    end
  end

  def fields_for_etc(index:, field:)
    fields_for('clause[]', index, include_id: false) do |foo|
      content_tag(:div, class: 'form-group advanced-search-field row mb-3') do
        foo.label(:query, field.display_label('search'), class: "col-sm-3 col-form-label text-md-right") +
          content_tag(:div, class: 'col-sm-9') do
            foo.hidden_field(:field, value: field.key) +
              foo.text_field(:query, value: query_for_search_clause(field.key), class: 'form-control')
          end
      end
    end
  end
end
