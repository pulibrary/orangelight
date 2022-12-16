# frozen_string_literal: true

document_url = polymorphic_url(@document)
json.links do
  json.self document_url
end

json.data do
  json.id @document.id
  json.type @document[blacklight_config.view_config(:show).display_type_field]
  json.attributes do
    doc_presenter = show_presenter(@document)

    # override Blacklight to render all fields instead of only those that display in HTML
    document_show_fields(@document).each do |field_name, field|
      next unless doc_presenter.document[field_name]
      json.partial! 'field', field:,
                             field_name:,
                             document_url:,
                             doc_presenter:
    end
  end
end
