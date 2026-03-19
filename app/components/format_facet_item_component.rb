# frozen_string_literal: true

class FormatFacetItemComponent < Blacklight::Facets::ItemComponent
  def render_facet_value(...)
    render_icon + super
  end

  def render_selected_facet_value(...)
    render_icon + super
  end

  private

    def render_icon
      content_tag :span, '', { class: "icon icon-#{@facet_item.value.parameterize}", aria: { hidden: true } }
    end
end
