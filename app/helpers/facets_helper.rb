# frozen_string_literal: true

module FacetsHelper
  include Blacklight::FacetsHelperBehavior

  def initial_collapse(field, display_facet)
    if display_facet.class == Blacklight::Solr::Response::Facets::FacetItem
      pivot_facet_child_in_params?(field, display_facet) ? 'collapse in' : 'collapse'
    else
      'facet-values'
    end
  end

  def facet_value_id(display_facet)
    display_facet.respond_to?('value') ? "id=#{display_facet.field.parameterize}-#{display_facet.value.parameterize}" : ''
  end

  def pivot_facet_child_in_params?(field, item, pivot_in_params = false)
    field = item.field if item&.respond_to?(:field)

    value = facet_value_for_facet_item(item)

    pivot_in_params = true if params[:f] && params[:f][field] && params[:f][field].include?(value)
    if item.items.present?
      item.items.each { |pivot_item| pivot_in_params = true if pivot_facet_child_in_params?(pivot_item.field, pivot_item) }
    end
    pivot_in_params
  end

  def pivot_facet_in_params?(field, item)
    field = item.field if item&.respond_to?(:field)

    value = facet_value_for_facet_item(item)
    params[:f] && params[:f][field] && params[:f][field].include?(value)
  end

  ##
  # Standard display of a SELECTED facet value (e.g. without a link and with a remove button)
  # @params (see #render_facet_value)
  def render_selected_facet_value(facet_field, item)
    content_tag(:span, class: 'facet-label') do
      content_tag(:span, facet_display_value(facet_field, item), class: 'selected') +
        # remove link
        link_to(content_tag(:i, '', :class => 'fa fa-times', 'aria-hidden' => 'true', 'data-toggle' => 'tooltip', 'data-original-title' => 'Remove') +
                content_tag(:span, '[remove]', class: 'sr-only'), search_action_path(search_state.remove_facet_params(facet_field, item)), class: 'remove')
    end + render_facet_count(item.hits, classes: ['selected'])
  end

  ##
  # Are any facet restrictions for a field in the query parameters?
  #
  # @param [String] facet field
  # @return [Boolean]
  def facet_field_in_params?(field)
    pivot = facet_configuration_for_field(field).pivot
    if pivot
      pivot_facet_field_in_params?(pivot)
    else
      params[:f] && params[:f][field]
    end
  end

  def pivot_facet_field_in_params?(pivot)
    in_params = false
    pivot.each { |field| in_params = true if params[:f] && params[:f][field] }
    in_params
  end

  def render_home_facets
    render_facet_partials home_facets
  end

  def home_facets
    blacklight_config.facet_fields.select { |_, v| v[:home] }.keys
  end

  def render_facet_partials(fields = facet_field_names, options = {})
    super
  rescue StandardError => error
    Rails.logger.error("#{self.class}: Failed to render the facet partials for #{fields.join(',')}: #{error}")
    head :bad_request if respond_to?(:head)
  end
end
