# frozen_string_literal: true

module Orangelight
  class MarkAsSafeProcessor < Blacklight::Rendering::AbstractStep
    def render
      next_step(config.mark_as_safe ? values.map(&:html_safe) : values)
    end
  end
end
