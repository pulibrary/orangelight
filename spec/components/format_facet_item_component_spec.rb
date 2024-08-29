# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormatFacetItemComponent, type: :component do
  it "includes an icon" do
    facet_item = instance_double(
      Blacklight::FacetItemPresenter,
      facet_config: Blacklight::Configuration::FacetField.new,
      value: 'Audio',
      label: 'Audio',
      hits: 4,
      href: '/?f%5Bformat%5D%5B%5D=Audio',
      selected?: false
    )
    rendered_facet = render_inline(described_class.new(facet_item:))
    expect(
      rendered_facet.css("span.icon.icon-audio")
    ).to be_truthy
  end
end
