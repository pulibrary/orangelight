# frozen_string_literal: true
module Orangelight
  class LanguageTagProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::TagHelper

    def render
      if config.language_tag && language_code
        next_step(values.map { content_tag(:span, it, lang: language_code) })
      else
        next_step(values)
      end
    end

      private

        def language_code
          document[:language_iana_s]&.first
        end
  end
end
