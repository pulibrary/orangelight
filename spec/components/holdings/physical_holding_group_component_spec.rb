# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::PhysicalHoldingGroupComponent, type: :component do
  it 'renders a details element' do
    group = Requests::HoldingGroup.new(group_name: 'Firestone Library - Remote Storage (ReCAP)', holdings: [])
    adapter = instance_double(HoldingRequestsAdapter)
    rendered = render_inline(described_class.new(group:, adapter:))

    expect(rendered.css('details')).to be_present
  end
end
