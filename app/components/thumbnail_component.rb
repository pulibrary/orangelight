# frozen_string_literal: true

# This component renders the necessary HTML markup
# to provide thumbnails in the search result and
# show pages from 3 different sources:
#   * default format-based thumbnails (added via CSS)
#   * Google Books thumbnails (added via JS)
#   * Figgy thumbnails (added via JS)
class ThumbnailComponent < ViewComponent::Base
  def initialize(document:)
    @document = document
  end

  private

    attr_accessor :document

    def identifier_data
      all_identifiers = document.identifier_data
      if document.in_a_special_collection?
        all_identifiers.slice(:'bib-id')
      else
        all_identifiers
      end
    end

    def thumbnail_display
      document["thumbnail_display"]
    end
end
