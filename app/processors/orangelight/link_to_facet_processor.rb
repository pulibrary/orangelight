# frozen_string_literal: true

module Orangelight
  class LinkToFacetProcessor < Blacklight::Rendering::LinkToFacet
    def link(field, v)
      context.link_to(v, search_path(field, v), class: 'search-name', data: { toggle: 'tooltip', original_title: "Search: #{v}" }, title: "Search: #{v}")
    end
  end
end
