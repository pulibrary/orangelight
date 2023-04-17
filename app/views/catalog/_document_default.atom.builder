# frozen_string_literal: true

xml.entry do
  xml.title document[:title_display]

  # updated is required, for now we'll just set it to now, sorry
  xml.updated document['cataloged_tdt']

  xml.link    'rel' => 'alternate', 'type' => 'text/html', 'href' => polymorphic_url(search_state.url_for_document(document))
  # add other doc-specific formats, atom only lets us have one per
  # content type, so the first one in the list wins.
  xml << document_presenter(document).link_rel_alternates(unique: true)

  xml.id polymorphic_url(search_state.url_for_document(document))

  xml.author { xml.name(document.to_semantic_values[:author].first) } if document.to_semantic_values.key? :author

  with_format(:html) do
    xml.summary 'type' => 'html' do
      xml.text! render partial: 'atom_index', locals: { document: }
    end
  end

  # If they asked for a format, give it to them.
  if params['content_format'] &&
     document.export_formats[params['content_format'].to_sym]

    type = document.export_formats[params['content_format'].to_sym][:content_type]

    xml.content type: type do |content_element|
      data = document.export_as(params['content_format'])

      # encode properly. See:
      # http://tools.ietf.org/html/rfc4287#section-4.1.3.3
      type = type.downcase
      if /\+|\/xml$/.match?(type.downcase)
        # xml, just put it right in
        content_element << data
      elsif /text\//.match?(type.downcase)
        # text, escape
        content_element.text! data
      else
        # something else, base64 encode it
        content_element << Base64.encode64(data)
      end
    end

  end
end
