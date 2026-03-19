# frozen_string_literal: true

module Orangelight
  # This processor is responsible for adding list markup to values when
  # there are multiple values
  class ListProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Context
    include ActionView::Helpers::TextHelper

    def render
      next_step(case values.length
                when (2..)
                  values.map.with_index { |value, index| content_tag(:li, value, class: css_class(index), dir: direction(value)) }
                when 1
                  [values.first]
                else
                  values
                end)
    end

    private

      delegate :maxInitialDisplay, to: :config

      # :reek:UtilityFunction
      def direction(value)
        return 'rtl' if value.dir == 'rtl' || value.include?('dir="rtl"')
        'ltr'
      end

      def css_class(index)
        class_string = "blacklight-#{config.key}"
        class_string = "#{class_string} d-none" if maxInitialDisplay && index >= maxInitialDisplay
        class_string
      end
  end
end
