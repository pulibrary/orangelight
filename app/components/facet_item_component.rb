# frozen_string_literal: true

# Overriding the Blacklight component in order to include
# our local customizations to facet display.  Currently
# only includes one override, to add PUL's tooltips for
# the removal icon, but we may add more overrides as
# we migrate to components.
class FacetItemComponent < Blacklight::FacetItemComponent
  def render_selected_facet_value
    tag.span(class: "facet-label") do
      tag.span(@label, class: "selected") +
        # remove link
        link_to(@href, class: "remove", rel: "nofollow") do
          # Add our custom tooltip
          tag.i(class: "fa fa-times", aria: { hidden: true }, data: { toggle: 'tooltip', original_title: 'Remove' }) +
            tag.span(helpers.t(:'blacklight.search.facets.selected.remove'), class: 'sr-only visually-hidden')
        end
    end + render_facet_count(classes: ["selected"])
  end
end
