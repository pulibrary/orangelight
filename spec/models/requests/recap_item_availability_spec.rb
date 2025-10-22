# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::RecapItemAvailability, :requests do
  it 'adds a status label' do
    scsb_availability_stub = stub_request(:post, 'https://scsb.recaplib.org:9093/sharedCollection/bibAvailabilityStatus')
                             .to_return(body: '[{"itemBarcode":"33333081091841","itemAvailabilityStatus":"Available","errorMessage":null,"collectionGroupDesignation":"Shared"}]')
    availability = described_class.new(id: '.b22165219x', scsb_location: 'scsbnypl')
    items = [{ 'barcode' => '33333081091841' }]

    expect(availability.items_with_availability(items:)).to eq([{ 'barcode' => '33333081091841', 'status' => nil, status_label: nil, 'status_label' => 'Available' }])
    expect(scsb_availability_stub).to have_been_requested
  end

  it 'does not modify status labels if the SCSB response does not include the barcode in question' do
    scsb_availability_stub = stub_request(:post, 'https://scsb.recaplib.org:9093/sharedCollection/bibAvailabilityStatus')
                             .to_return(body: '[{"itemBarcode":"INCORRECT_BARCODE","itemAvailabilityStatus":"Available","errorMessage":null,"collectionGroupDesignation":"Shared"}]')
    availability = described_class.new(id: '.b22165219x', scsb_location: 'scsbnypl')
    items = [{ 'barcode' => '33333081091841' }]

    expect(availability.items_with_availability(items:)).to eq([{ 'barcode' => '33333081091841', status_label: nil }])
    expect(scsb_availability_stub).to have_been_requested
  end
end
