# frozen_string_literal: true

module Orangelight
  class JoinProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Context
    include ActionView::Helpers::TextHelper

    def render
      return next_step(values) if values.blank?
      return next_step(values.first) if values.length == 1

      joined = content_tag :ul do
        values.each_with_index do |value, index|
          list_item = content_tag(:li, value, class: css_class(index), dir: direction(value))
          concat list_item
        end
      end
      next_step(joined)
    end

    private

      def direction(value)
        return 'rtl' if value.dir == 'rtl' || value.include?('dir="rtl"')
        'ltr'
      end

      def css_class(index)
        class_string = "blacklight-#{config.key}"
        class_string = "#{class_string} d-none" if config.maxInitialDisplay && index >= config.maxInitialDisplay
        class_string
      end
  end
end
