# frozen_string_literal: true
module Orangelight
  # For reference notes that end with a url convert the note into link
  class ReferenceNoteUrlProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::UrlHelper
    def render
      return next_step(values) unless config.references_url
      values.map! do |reference|
        if (url = reference[/ (http.*)$/])
          chomped = reference.chomp(url)
          reference = link_to(chomped, url.gsub(/\s/, ''), target: '_blank', rel: 'noopener')
        end
        reference
      end

      next_step(values)
    end
  end
end
