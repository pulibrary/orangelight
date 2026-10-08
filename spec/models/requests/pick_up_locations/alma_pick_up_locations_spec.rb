# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::PickUpLocations::AlmaPickUpLocations, :requests do
  it 'uses default_pick_ups from the form when the location has no pickup locations' do
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'Stokes Library', gfa_pickup: 'PM' }])
    requestable = instance_double(Requests::Requestable, location: {}, patron: instance_double(Requests::Patron, library_staff_patron_group?: false, affiliate_patron_group?: false, eligible_faculty_pickup_pppl?: false))
    locations = described_class.new(form:, requestable:)

    expect(locations.call).to eq([{ label: 'Stokes Library', gfa_pickup: 'PM' }])
  end
end
