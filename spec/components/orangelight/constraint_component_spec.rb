# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::ConstraintComponent, type: :component do
  let(:facet_item_presenter) { instance_double(Blacklight::FacetItemPresenter) }

  it "can handle the odd format[0]-style params" do
    allow(facet_item_presenter).to receive(:key).and_return('key')
    allow(facet_item_presenter).to receive(:field_label).and_return('Format')
    allow(facet_item_presenter).to receive(:constraint_label).and_return({ "0" => "Audio" }.with_indifferent_access)
    allow(facet_item_presenter).to receive(:remove_href).and_return('/bye')

    component = described_class.new(facet_item_presenter:)
    expect(render_inline(component).to_s).to include('Format: Audio')
  end
end
