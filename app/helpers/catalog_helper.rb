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

  # Returns array with only 2 arks.
  # Currenlty is used in the catalog/show.html.erb
  # for the figgy ajax call in the figgy_viewer_loader.js
  def ark_array
    doc_hash = @document.select { |key, value| value if key == 'electronic_access_1display' }.to_h
    res_parse = JSON.parse(doc_hash['electronic_access_1display'])
    res = res_parse.map { |key, _value| key.sub('http://arks.princeton.edu/', '') }
    res[0..1]
  end

  private

    def document_types(document)
      document[blacklight_config.view_config(document_index_view_type).display_type_field]
    end
end
