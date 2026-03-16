# frozen_string_literal: true
require 'rails_helper'

class FakeBibdataService
  def self.delivery_locations
    {
      'PA' => { 'label' => 'Firestone Library', 'gfa_pickup' => 'PA' },
      'PK' => { 'label' => 'Mendel Music Library', 'gfa_pickup' => 'PK' },
      'PL' => { 'label' => 'East Asian Library', 'gfa_pickup' => 'PL' },
      'PM' => { 'label' => 'Stokes Library', 'gfa_pickup' => 'PM' },
      'PN' => { 'label' => 'Lewis Library', 'gfa_pickup' => 'PN' },
      'PT' => { 'label' => 'Engineering Library', 'gfa_pickup' => 'PT' },
      'PW' => { 'label' => 'Architecture Library', 'gfa_pickup' => 'PW' }
    }
  end
end

RSpec.describe Requests::PickUpLocations::ILLPickUpLocations, :requests do
  it 'returns PA if the ILLiad user account is Firestone' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Firestone' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Firestone Library', 'gfa_pickup' => 'PA' }])
  end
  it 'returns PK if the ILLiad user account is Music' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Music' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Mendel Music Library', 'gfa_pickup' => 'PK' }])
  end
  it 'returns PL if the ILLiad user account is East Asian' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'East Asian' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'East Asian Library', 'gfa_pickup' => 'PL' }])
  end
  it 'returns PM if the ILLiad user account is Stokes' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Stokes' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Stokes Library', 'gfa_pickup' => 'PM' }])
  end
  it 'returns PT if the ILLiad user account is Engineering' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Engineering' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Engineering Library', 'gfa_pickup' => 'PT' }])
  end
  it 'returns PW if the ILLiad user account is Architecture' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Architecture' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Architecture Library', 'gfa_pickup' => 'PW' }])
  end
  it 'returns PA if the ILLiad user account is an unexpected value' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Some Bad Data' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Firestone Library', 'gfa_pickup' => 'PA' }])
  end
  it 'returns PA if the ILLiad user account is missing the Site' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { UserName: 'jstudent' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Firestone Library', 'gfa_pickup' => 'PA' }])
  end
  it 'returns PA if the ILLiad call returned False (such as during a network error)' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: false)
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call).to eq([{ 'label' => 'Firestone Library', 'gfa_pickup' => 'PA' }])
  end
end
