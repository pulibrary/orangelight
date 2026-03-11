# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::PickUpLocations::ScsbPickUpLocations do
  it 'uses default_pick_ups from the form when the location has no pickup locations' do
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'Stokes Library', gfa_pickup: 'PM' }])
    requestable = instance_double(Requests::Requestable, item: {}, location: {})
    locations = described_class.new(form:, requestable:)

    expect(locations.call).to eq([{ label: 'Stokes Library', gfa_pickup: 'PM' }])
  end

  it 'does not include locations that are not valid pickup locations' do
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'Stokes Library', gfa_pickup: 'PM' }])
    # QK (Mendel Sound/Video) is not a valid pickup location)
    requestable = instance_double(Requests::Requestable, item: {}, location: { delivery_locations: [{ label: 'Mendel Music Library. Sound/Video', gfa_pickup: 'QK' }] })
    locations = described_class.new(form:, requestable:)

    expect(locations.call).to eq([{ label: 'Stokes Library', gfa_pickup: 'PM' }])
  end
end
