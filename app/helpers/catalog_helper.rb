# frozen_string_literal: true

module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  ##
  # Get the classes to add to a document's div
  #
  # @return [String]
  def render_document_class(document = @document)
    types = document_types(document)
    return if types.blank?
    type = types.first
    "#{document_class_prefix}#{type.try(:parameterize) || type}"
  end

  # Determine whether or not to render the availability
  #
  # @return [TrueClass, FalseClass]
  def render_availability?
    !request.bot?
  end

  # @see Blacklight::CatalogHelperBehavior#render_search_to_page_title_filter
  # @param [facet]
  # @param [values]
  def render_search_to_page_title_filter(facet, values)
    return '' if values.blank?
    super(facet, values)
  end

  # @see Blacklight::CatalogHelperBehavior#render_search_to_page_title
  # @param [params]
  def render_search_to_page_title(params)
    constraints = []

    if params['q'].present?
      q_label = label_for_search_field(params[:search_field]) unless default_search_field && params[:search_field] == default_search_field[:key]

      constraints += if q_label.present?
                       [t('blacklight.search.page_title.constraint', label: q_label, value: params['q'])]
                     else
                       [params['q']]
                     end
    end

    if params['f'].present?
      new_constraints = params['f'].to_unsafe_h.collect { |key, value| render_search_to_page_title_filter(key, value) }
      constraints += new_constraints.reject(&:empty?)
    end

    constraints.join(' / ')
  end

  def render_top_field?(document, field, field_name)
    !should_render_show_field?(document, field) && document[field_name].present? &&
      field_name != 'holdings_1display'
  end

  private

    def document_types(document)
      document[blacklight_config.view_config(document_index_view_type).display_type_field]
    end
end
