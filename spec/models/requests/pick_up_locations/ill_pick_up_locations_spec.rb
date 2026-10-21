# frozen_string_literal: true
require 'rails_helper'

class FakeBibdataService
  # rubocop:disable-next Metrics/MethodLength
  def self.delivery_locations
    [
      { "label" => "Plasma Physics Library", "address" => "Forrestal Campus Princeton, NJ 08544", "phone_number" => "609-243-3565", "contact_email" => "lewislib@princeton.edu", "gfa_pickup" => "PQ", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/1.json", "library" => { "label" => "Harold P. Furth Plasma Physics Library", "code" => "plasma", "order" => 0 } },
      { "label" => "Technical Services 693", "address" => "693 Alexander Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "catalogn@princeton.edu", "gfa_pickup" => "QT", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/2.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Architecture Library", "address" => "School of Architecture Building, Second Floor Princeton, NJ 08544", "phone_number" => "609-258-3256", "contact_email" => "ues@princeton.edu", "gfa_pickup" => "PW", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/3.json", "library" => { "label" => "Architecture Library", "code" => "arch", "order" => 0 } },
      { "label" => "East Asian Library", "address" => "Frist Campus Center, Room 317 Princeton, NJ 08544", "phone_number" => "609-258-3182", "contact_email" => "gestcirc@princeton.edu", "gfa_pickup" => "PL", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/4.json", "library" => { "label" => "East Asian Library", "code" => "eastasian", "order" => 0 } },
      { "label" => "Engineering Library", "address" => "Friend Center for Engineering Education Princeton, NJ 08544", "phone_number" => "609-258-3200", "contact_email" => "englib@princeton.edu", "gfa_pickup" => "PT", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/5.json", "library" => { "label" => "Engineering Library", "code" => "engineer", "order" => 0 } },
      { "label" => "Firestone Library", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-3252", "contact_email" => "microfms@princeton.edu", "gfa_pickup" => "PF", "staff_only" => false, "pickup_location" => true, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/6.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Marquand Library of Art and Archaeology", "address" => "McCormick Hall Princeton, NJ 08544", "phone_number" => "609-258-5863", "contact_email" => "marquand@princeton.edu", "gfa_pickup" => "PJ", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/7.json", "library" => { "label" => "Marquand Library", "code" => "marquand", "order" => 0 } },
      { "label" => "Mendel Music Library", "address" => "Woolworth Center Princeton, NJ 08544", "phone_number" => "609-258-3230", "contact_email" => "muslib@princeton.edu", "gfa_pickup" => "PK", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/8.json", "library" => { "label" => "Mendel Music Library", "code" => "mendel", "order" => 0 } },
      { "label" => "Mudd Manuscript Library", "address" => "65 Olden Street Princeton, NJ 08544", "phone_number" => "609-258-6345", "contact_email" => "mudd@princeton.edu", "gfa_pickup" => "PH", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/9.json", "library" => { "label" => "Mudd Manuscript Library", "code" => "mudd", "order" => 0 } },
      { "label" => "Stokes Library", "address" => "Wallace Hall, Lower Level Princeton, NJ 08544", "phone_number" => "609-258-5455", "contact_email" => "piaprlib@princeton.edu", "gfa_pickup" => "PM", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/10.json", "library" => { "label" => "Stokes Library", "code" => "stokes", "order" => 0 } },
      { "label" => "Resource Sharing", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "QA", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/12.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Special Collections", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "rbsc@princeton.edu", "gfa_pickup" => "PG", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/13.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Lewis Library", "address" => "Washington Road and Ivy Lane Princeton, NJ 08544", "phone_number" => "609-258-6004", "contact_email" => "lewislib@princeton.edu", "gfa_pickup" => "PN", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/14.json", "library" => { "label" => "Lewis Library", "code" => "lewis", "order" => 0 } },
      { "label" => "Firestone Library", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "PA", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "url" => "https://localhost:3009/locations/delivery_locations/15.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "ReCAP ILL", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "IL", "staff_only" => true, "pickup_location" => false, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/16.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Technical Services HMT", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "catalogn@princeton.edu", "gfa_pickup" => "QC", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/23.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "East Asian Library. Microforms", "address" => "Frist Campus Center, Room 317 Princeton, NJ 08544", "phone_number" => "609-258-3182", "contact_email" => "gestcirc@princeton.edu", "gfa_pickup" => "QL", "staff_only" => false, "pickup_location" => false, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/24.json", "library" => { "label" => "East Asian Library", "code" => "eastasian", "order" => 0 } },
      { "label" => "Lewis Library (Rare)", "address" => "Washington Road and Ivy Lane Princeton, NJ 08544", "phone_number" => "609-258-6004", "contact_email" => "lewislib@princeton.edu", "gfa_pickup" => "PS", "staff_only" => false, "pickup_location" => false, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/25.json", "library" => { "label" => "Lewis Library", "code" => "lewis", "order" => 0 } },
      { "label" => "Marquand Library of Art and Archaeology (Rare)", "address" => "McCormick Hall Princeton, NJ 08544", "phone_number" => "609-258-5863", "contact_email" => "marquand@princeton.edu", "gfa_pickup" => "PZ", "staff_only" => false, "pickup_location" => false, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/26.json", "library" => { "label" => "Marquand Library", "code" => "marquand", "order" => 0 } },
      { "label" => "Mendel Music Library. Sound/Video", "address" => "Woolworth Center Princeton, NJ 08544", "phone_number" => "609-258-3230", "contact_email" => "muslib@princeton.edu", "gfa_pickup" => "QK", "staff_only" => false, "pickup_location" => false, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/27.json", "library" => { "label" => "Mendel Music Library", "code" => "mendel", "order" => 0 } },
      { "label" => "Firestone Library", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-3252", "contact_email" => "microfms@princeton.edu", "gfa_pickup" => "PB", "staff_only" => false, "pickup_location" => true, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/28.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Preservation", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "QP", "staff_only" => true, "pickup_location" => false, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/29.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
      { "label" => "Firestone Circulation Desk", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609 258-2345", "contact_email" => "fstcirc@princton.edu", "gfa_pickup" => "QX", "staff_only" => false, "pickup_location" => true, "digital_location" => false, "url" => "https://localhost:3009/locations/delivery_locations/30.json", "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }
    ]
  end
end

RSpec.describe Requests::PickUpLocations::ILLPickUpLocations, :requests do
  it 'returns PA if the ILLiad user account is Firestone' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Firestone' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)
    expect(locations.call.first).to include('label' => 'Firestone Library', 'gfa_pickup' => 'PA')
  end
  it 'returns PK if the ILLiad user account is Music' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Music' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Mendel Music Library', 'gfa_pickup' => 'PK')
  end
  it 'returns PL if the ILLiad user account is East Asian' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'East Asian' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'East Asian Library', 'gfa_pickup' => 'PL')
  end
  it 'returns PM if the ILLiad user account is Stokes' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Stokes' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Stokes Library', 'gfa_pickup' => 'PM')
  end
  it 'returns PT if the ILLiad user account is Engineering' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Engineering' }, patron: instance_double(Requests::Patron, eligible_pickup_from_pppl?: true))
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Engineering Library', 'gfa_pickup' => 'PT')
  end
  it 'returns PW if the ILLiad user account is Architecture' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Architecture' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Architecture Library', 'gfa_pickup' => 'PW')
  end
  it 'returns PA if the ILLiad user account is an unexpected value' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { Site: 'Some Bad Data' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Firestone Library', 'gfa_pickup' => 'PA')
  end
  it 'returns PA if the ILLiad user account is missing the Site' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: { UserName: 'jstudent' })
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Firestone Library', 'gfa_pickup' => 'PA')
  end
  it 'returns PA if the ILLiad call returned False (such as during a network error)' do
    requestable = instance_double(Requests::Requestable)
    form = instance_double(Requests::Form, illiad_account: false)
    locations = described_class.new(requestable:, form:, bibdata_service_class: FakeBibdataService)

    expect(locations.call.first).to include('label' => 'Firestone Library', 'gfa_pickup' => 'PA')
  end
end
