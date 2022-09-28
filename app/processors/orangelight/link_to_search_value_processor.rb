# frozen_string_literal: true

module Orangelight
  class LinkToSearchValueProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::UrlHelper

    def render
      return next_step(values) unless config.link_to_search_value

      values.map! do |value|
        link_to(value, "/?f[#{config.key}][]=#{CGI.escape value}", class: 'search-name', 'data-toggle' => 'tooltip', 'data-original-title' => "Search: #{value}")
      end
      next_step(values)
    end
  end
end
