# frozen_string_literal: true

module Orangelight
  class HighlightProcessor < Blacklight::Rendering::AbstractStep
    def render
      next_step(values.map { |value| value.gsub('<em>', '<em class="highlight-query">').gsub('</em>', '</em class="highlight-query">').html_safe })
    end
  end
end
