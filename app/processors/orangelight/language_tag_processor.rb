# frozen_string_literal: true
module Orangelight
  class LanguageTagProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::TagHelper

    def render
      if config.language_tag
        next_step(values.map do |value|
          tag = LanguageTag.from_value(value, document)
          if tag
            content_tag(:span, value, lang: tag)
          else
            value
          end
        end)
      else
        next_step(values)
      end
    end
  end
end
