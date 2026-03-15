# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::PickUpLocations::PickUpLocationsFactory, :requests do
  before { stub_delivery_locations }
  it 'returns pickup locations for on-shelf Firestone title' do
    location = Requests::Location.new single_holding_data_from_fixture('firestone$stacks')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: false, annex?: false, recap?: false)
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
    location = Requests::Location.new single_holding_data_from_fixture('rare$crare')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::RequestableDecorator, partner_holding?: false, location:, ill_eligible?: false, annex?: false, recap?: false, delivery_location_code: 'PL', pick_up_location_code: 'PL', delivery_location_label: 'East Asian Library')
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["East Asian Library", "PL"]
                                                          ])
  end

  it 'returns pickup locations for a marquand$pz book' do
    location = Requests::Location.new single_holding_data_from_fixture('marquand$pz')
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::RequestableDecorator, partner_holding?: false, location:, ill_eligible?: false, annex?: false, recap?: false, delivery_location_code: 'PJ', pick_up_location_code: 'PJ', delivery_location_label: 'Marquand Library of Art and Archaeology')
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Marquand Library of Art and Archaeology", "PJ"]
                                                          ])
  end

  it 'returns a single pickup location for SCSB partner with no restrictions' do
    location = single_holding_data_from_fixture('scsbcul')
    item = { collection_code: 'CU' }.with_indifferent_access
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: true, item:, location:, ill_eligible?: false, annex?: false, recap?: true)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Firestone Circulation Desk", "QX"]
                                                          ])
  end

  it 'returns a single pickup location for a SCSB Item from a restricted Art-related collection code' do
    location = single_holding_data_from_fixture('scsbcul')
    item = { collection_code: 'AR' }.with_indifferent_access
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: true, item:, location:, ill_eligible?: false, annex?: false, recap?: true)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Marquand Library of Art and Archaeology", "PJ"]
                                                          ])
  end

  it 'returns a single pickup location for a SCSB Item from a restricted Music-related collection code' do
    location = single_holding_data_from_fixture('scsbcul')
    item = { collection_code: 'MR' }.with_indifferent_access
    form = instance_double(Requests::Form)
    requestable = instance_double(Requests::Requestable, partner_holding?: true, item:, location:, ill_eligible?: false, annex?: false, recap?: true)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Mendel Music Library", "PK"]
                                                          ])
  end

  it 'returns a single pickup location (Firestone) for Interlibrary loans' do
    location = single_holding_data_from_fixture('firestone$stacks')
    form = instance_double(Requests::Form, illiad_account: { Site: 'Firestone' })
    requestable = instance_double(Requests::Requestable, partner_holding?: false, location:, ill_eligible?: true, annex?: false, recap?: false)
    factory = described_class.new(form:, requestable:)

    expect(factory.call.pluck(:label, :gfa_pickup)).to eq([
                                                            ["Firestone Library", "PA"]
                                                          ])
  end
end
