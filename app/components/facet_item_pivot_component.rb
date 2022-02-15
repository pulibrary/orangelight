# frozen_string_literal: true

class FacetItemPivotComponent < Blacklight::FacetItemPivotComponent
  def facet_toggle_button(id)
    content_tag 'a', class: 'icon toggle collapsed',
                     href: '#',
                     data: { toggle: 'collapse', 'bs-toggle': 'collapse', target: "##{id}", 'bs-target': "##{id}" },
                     aria: { expanded: false, controls: id, describedby: "#{id}_label" } do
      concat toggle_icon(:show)
      concat toggle_icon(:hide)
    end
  end
end
