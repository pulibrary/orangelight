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

  private
  def document_types(document)
    document[blacklight_config.view_config(document_index_view_type).display_type_field]
  end
end
