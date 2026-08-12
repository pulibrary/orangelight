# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::PhysicalHoldingGroupComponent, type: :component do
  it 'renders a details element' do
    allow(Flipflop).to receive(:deduplication?).and_return false
    group = Requests::HoldingGroup.new(group_name: 'Firestone Library - Remote Storage (ReCAP)', holdings: [])
    adapter = instance_double(HoldingRequestsAdapter)
    rendered = render_inline(described_class.new(group:, adapter:))

    expect(rendered.css('details')).to be_present
  end

  it 'renders an open details element if open: true' do
    allow(Flipflop).to receive(:deduplication?).and_return false
    group = Requests::HoldingGroup.new(group_name: 'Firestone Library - Remote Storage (ReCAP)', holdings: [])
    adapter = instance_double(HoldingRequestsAdapter)
    rendered = render_inline(described_class.new(group:, adapter:, open: true))

    expect(rendered.css('details[open]')).to be_present
  end

  it 'has table headers' do
    allow(Flipflop).to receive(:deduplication?).and_return false
    group = Requests::HoldingGroup.new(group_name: 'Firestone Library - Remote Storage (ReCAP)', holdings: [])
    adapter = instance_double(HoldingRequestsAdapter)
    rendered = render_inline(described_class.new(group:, adapter:, open: true))
    headers = rendered.css('th').map(&:text)

    expect(headers).to eq ['Call Number', 'Status', 'Location Service']
  end

  it 'includes a format in the headers when using deduplication feature' do
    allow(Flipflop).to receive(:deduplication?).and_return true
    group = Requests::HoldingGroup.new(group_name: 'Firestone Library - Remote Storage (ReCAP)', holdings: [])
    adapter = instance_double(HoldingRequestsAdapter)
    rendered = render_inline(described_class.new(group:, adapter:, open: true))
    headers = rendered.css('th').map(&:text)

    expect(headers).to eq ['Format', 'Call Number', 'Status', 'Location Service']
  end
end
