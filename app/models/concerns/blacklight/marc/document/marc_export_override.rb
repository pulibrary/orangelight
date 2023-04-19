# frozen_string_literal: true

module Blacklight::Marc::Document::MarcExportOverride
  # Override Blacklight's version to add nil check
  # See https://github.com/projectblacklight/blacklight-marc/issues/95
  def clean_end_punctuation(text)
    # rubocop:disable Style/IfUnlessModifier
    return "" if text.nil?
    if [".", ",", ":", ";", "/"].include? text[-1, 1]
      return text[0, text.length - 1]
    end
    text
    # rubocop:enable Style/IfUnlessModifier
  end
end
