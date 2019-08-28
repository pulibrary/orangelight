# frozen_string_literal: true

json.set!(field_name) do
  json.id "#{document_url}##{field_name}"
  json.type 'document_value'
  json.attributes do
    if field_name.end_with?('1display') # convert json strings to hashes
      json.value JSON.parse(doc_presenter.document[field_name])
    else
      json.value doc_presenter.document[field_name]
    end
    json.label field.label
  end
end
