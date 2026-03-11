# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::PickUpLocations::PickUpLocationsFactory do
  before { stub_delivery_locations }
  it 'returns pickup locations for on-shelf Firestone title' do
    location = single_holding_data_from_fixture('firestone$stacks')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Architecture Library", "PW"],
                                                            ["East Asian Library", "PL"],
                                                            ["Engineering Library", "PT"],
                                                            ["Mendel Music Library", "PK"],
                                                            ["Stokes Library", "PM"],
                                                            ["Firestone Library", "PA"]
                                                          ])
  end

  it 'returns pickup locations for on-shelf East Asian rare book' do
    location = single_holding_data_from_fixture('rare$crare')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["East Asian Library", "PL"]
                                                          ])
  end

  it 'returns pickup locations for a marquand$pz book' do
    location = single_holding_data_from_fixture('marquand$pz')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Marquand Library of Art and Archaeology", "PJ"]
                                                          ])
  end

  it 'returns default pickups for a location without delivery locations' do
    location = single_holding_data_from_fixture('rare$thx')
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'I Am Default', gfa_pickup: 'DF' }])
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["I Am Default", "DF"]
                                                          ])
  end

  it 'returns default pickups for a in item that is being shared with another institution' do
    location = single_holding_data_from_fixture('RES_SHARE$OUT_RS_REQ')
    form = instance_double(Requests::Form, default_pick_ups: [{ label: 'I Am Default', gfa_pickup: 'DF' }])
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["I Am Default", "DF"]
                                                          ])
  end

  it 'returns a single pickup location for SCSB partner with no restrictions' do
    location = single_holding_data_from_fixture('scsbcul')
    item = { collection_code: 'CU' }.with_indifferent_access
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: true, item:, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Firestone Circulation Desk", "QX"]
                                                          ])
  end

  it 'returns a single pickup location for a SCSB Item from a restricted Art-related collection code' do
    location = single_holding_data_from_fixture('scsbcul')
    item = { collection_code: 'AR' }.with_indifferent_access
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: true, item:, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Marquand Library of Art and Archaeology", "PJ"]
                                                          ])
  end

  it 'returns a single pickup location for a SCSB Item from a restricted Music-related collection code' do
    location = single_holding_data_from_fixture('scsbcul')
    item = { collection_code: 'MR' }.with_indifferent_access
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: true, item:, location:, ill_eligible?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Mendel Music Library", "PK"]
                                                          ])
  end

  it 'returns a single pickup location (Firestone) for Interlibrary loans' do
    location = single_holding_data_from_fixture('firestone$stacks')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: true)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Firestone Library", "PA"]
                                                          ])
  end
end
