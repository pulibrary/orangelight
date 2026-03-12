# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::PickUpLocations::AnnexPickUpLocations, :requests do
  it 'filters out invalid pickup locations' do
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'Stokes Library', gfa_pickup: 'PM' }])
    custom_locations = [
      { label: "Valid Custom Location", gfa_pickup: "PJ", pick_up_location_code: "custom1", staff_only: false },
      { label: "Invalid Custom Location", gfa_pickup: "ZZ", pick_up_location_code: "custom2", staff_only: false }
    ]
    requestable = instance_double(Requests::RequestableDecorator, location: { delivery_locations: custom_locations })
    locations = described_class.new(form:, requestable:)

    # Only the first custom location should be returned (PJ is valid, ZZ is not)
    expect(locations.call).to eq([custom_locations[0]])
  end

  it 'returns the first default pickup location if there are no valid pickup locations in the requestable' do
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'Firestone Library', gfa_pickup: 'PA' }, { label: 'Architecture Library', gfa_pickup: 'PW' }])
    custom_locations = [
      { label: "Invalid Custom Location", gfa_pickup: "ZZ", pick_up_location_code: "custom2", staff_only: false }
    ]
    requestable = instance_double(Requests::RequestableDecorator, location: { delivery_locations: custom_locations })
    locations = described_class.new(form:, requestable:)

    expect(locations.call).to eq([{ label: 'Firestone Library', gfa_pickup: 'PA' }])
  end

  it 'returns all default pickup locations if there are no pickup locations at all in the requestable' do
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'Firestone Library', gfa_pickup: 'PA' }, { label: 'Architecture Library', gfa_pickup: 'PW' }])
    requestable = instance_double(Requests::RequestableDecorator, location: { delivery_locations: [] })
    locations = described_class.new(form:, requestable:)

    expect(locations.call).to eq([{ label: 'Firestone Library', gfa_pickup: 'PA' }, { label: 'Architecture Library', gfa_pickup: 'PW' }])
  end
end
