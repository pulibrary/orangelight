# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::Location, requests: true do
  describe '#library_label' do
    it 'takes the library label from the provided bibdata location hash' do
      location = described_class.new(JSON.parse('{"label":"English Theses","code":"annex$set","aeon_location":false,"recap_electronic_delivery_location":false,"open":false,"requestable":true,"always_requestable":false,"circulates":true,"remote_storage":"","fulfillment_unit":"Closed","library":{"label":"Forrestal Annex","code":"annex","order":0},"holding_library":null,"delivery_locations":[]}'))
      expect(location.library_label).to eq('Forrestal Annex')
    end
  end
  describe '#annex?' do
    it 'returns true if the library code is annex' do
      location = described_class.new(JSON.parse('{"label":"English Theses","code":"annex$set","aeon_location":false,"recap_electronic_delivery_location":false,"open":false,"requestable":true,"always_requestable":false,"circulates":true,"remote_storage":"","fulfillment_unit":"Closed","library":{"label":"Forrestal Annex","code":"annex","order":0},"holding_library":null,"delivery_locations":[]}'))
      expect(location.annex?).to be(true)
    end
  end

  describe '#engineering_library?' do
    it 'returns true if the label is Engineering Library' do
      location = described_class.new({ "label" => "Engineering Library", "code" => "engineer$stacks" })
      expect(location.engineering_library?).to be(true)
    end

    it 'returns false if the label is not Engineering Library' do
      location = described_class.new({ "label" => "Firestone Library", "code" => "firestone$stacks" })
      expect(location.engineering_library?).to be(false)
    end
  end
  describe '#sort_pick_ups' do
    let(:delivery_locations) do
      [{ "label" => "Technical Services 693", "address" => "693 Alexander Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "catalogn@princeton.edu", "gfa_pickup" => "QT", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }, { "label" => "Architecture Library", "address" => "School of Architecture Building, Second Floor Princeton, NJ 08544", "phone_number" => "609-258-3256", "contact_email" => "ues@princeton.edu", "gfa_pickup" => "PW", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Architecture Library", "code" => "arch", "order" => 0 } }, { "label" => "Firestone Library, Resource Sharing", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "QA", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
       { "label" => "Technical Services HMT", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "catalogn@princeton.edu", "gfa_pickup" => "QC", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }, { "label" => "Preservation", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "QP", "staff_only" => true, "pickup_location" => false, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }]
    end
    let(:delivery_locations_sorted) do
      [{ "label" => "Architecture Library", "address" => "School of Architecture Building, Second Floor Princeton, NJ 08544", "phone_number" => "609-258-3256", "contact_email" => "ues@princeton.edu", "gfa_pickup" => "PW", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Architecture Library", "code" => "arch", "order" => 0 } }, { "label" => "Firestone Library, Resource Sharing (Staff Only)", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "QA", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } },
       { "label" => "Preservation (Staff Only)", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "QP", "staff_only" => true, "pickup_location" => false, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }, { "label" => "Technical Services 693 (Staff Only)", "address" => "693 Alexander Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "catalogn@princeton.edu", "gfa_pickup" => "QT", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }, { "label" => "Technical Services HMT (Staff Only)", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "catalogn@princeton.edu", "gfa_pickup" => "QC", "staff_only" => true, "pickup_location" => true, "digital_location" => false, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }]
    end
    let(:location) { described_class.new({ delivery_locations: }) }

    it "sorts the delivery locations" do
      expect(location.sort_pick_ups).to eq(delivery_locations_sorted)
    end
  end
  describe '#build_delivery_locations' do
    context 'when the delivery location is in Firestone' do
      let(:delivery_locations) do
        [{ "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 } }]
      end
      let(:delivery_locations_built) do
        [{ "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }]
      end
      let(:location) { described_class.new({ delivery_locations: }) }
      it 'adds the pick_up_location_code of firestone' do
        expect(location.build_delivery_locations).to eq delivery_locations_built
      end
    end
    context 'when the delivery location is in Architecture' do
      let(:delivery_locations) do
        [{ "library" => { "label" => "Architecture Library", "code" => "arch", "order" => 0 } }]
      end
      let(:delivery_locations_built) do
        [{ "library" => { "label" => "Architecture Library", "code" => "arch", "order" => 0 }, "pick_up_location_code" => "arch" }]
      end
      let(:location) { described_class.new({ delivery_locations: }) }
      it 'adds the pick_up_location_code of arch' do
        expect(location.build_delivery_locations).to eq delivery_locations_built
      end
    end
  end

  describe '.filter_pick_up_locations_by_code' do
    let(:locations_with_pf) do
      [
        { label: "Firestone Library", gfa_pickup: "PA", staff_only: false },
        { label: "Firestone Library, Microforms", gfa_pickup: "PF", staff_only: false },
        { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }
      ]
    end

    context 'when code is firestone$pf' do
      it 'returns only locations with gfa_pickup PF' do
        result = described_class.filter_pick_up_locations_by_code(locations_with_pf, 'firestone$pf')
        expect(result).to eq([{ label: "Firestone Library, Microforms", gfa_pickup: "PF", staff_only: false }])
      end
    end

    context 'when code is not firestone' do
      it 'rejects locations with gfa_pickup PF' do
        result = described_class.filter_pick_up_locations_by_code(locations_with_pf, 'arch$stacks')
        expect(result).to eq([
                               { label: "Firestone Library", gfa_pickup: "PA", staff_only: false },
                               { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }
                             ])
      end
    end

    context 'when code starts with firestone but is not firestone$pf' do
      it 'rejects locations with gfa_pickup PF' do
        result = described_class.filter_pick_up_locations_by_code(locations_with_pf, 'firestone$stacks')
        expect(result).to eq([
                               { label: "Firestone Library", gfa_pickup: "PA", staff_only: false },
                               { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }
                             ])
      end
    end

    context 'when locations array is empty' do
      it 'returns empty array' do
        result = described_class.filter_pick_up_locations_by_code([], 'firestone$pf')
        expect(result).to eq([])
      end
    end

    context 'when code is blank' do
      it 'returns original locations' do
        result = described_class.filter_pick_up_locations_by_code(locations_with_pf, '')
        expect(result).to eq(locations_with_pf)
      end
    end
  end

  describe '#filter_pick_ups' do
    let(:delivery_locations_with_pf) do
      [
        { "label" => "Firestone Library", "gfa_pickup" => "PA", "staff_only" => false },
        { "label" => "Firestone Library, Microforms", "gfa_pickup" => "PF", "staff_only" => false },
        { "label" => "Architecture Library", "gfa_pickup" => "PW", "staff_only" => false }
      ]
    end

    context 'when location code is firestone$pf' do
      let(:location) { described_class.new({ "code" => "firestone$pf", "delivery_locations" => delivery_locations_with_pf }) }

      it 'filters to only PF locations' do
        result = location.filter_pick_ups
        expect(result).to eq([{ "label" => "Firestone Library, Microforms", "gfa_pickup" => "PF", "staff_only" => false }])
      end
    end

    context 'when location code is not firestone' do
      let(:location) { described_class.new({ "code" => "arch$stacks", "delivery_locations" => delivery_locations_with_pf }) }

      it 'rejects PF locations' do
        result = location.filter_pick_ups
        expect(result).to eq([
                               { "label" => "Firestone Library", "gfa_pickup" => "PA", "staff_only" => false },
                               { "label" => "Architecture Library", "gfa_pickup" => "PW", "staff_only" => false }
                             ])
      end
    end
  end

  describe '#sort_and_filter_pick_ups' do
    let(:delivery_locations_with_pf) do
      [
        { "label" => "Lewis Library", "gfa_pickup" => "PN", "staff_only" => false },
        { "label" => "Firestone Library", "gfa_pickup" => "PA", "staff_only" => false },
        { "label" => "Firestone Library, Microforms", "gfa_pickup" => "PF", "staff_only" => false },
        { "label" => "Architecture Library", "gfa_pickup" => "PW", "staff_only" => false },
        { "label" => "Technical Services HMT", "gfa_pickup" => "QC", "staff_only" => true }
      ]
    end

    context 'when location code is firestone$pf' do
      let(:location) { described_class.new({ "code" => "firestone$pf", "delivery_locations" => delivery_locations_with_pf }) }

      it 'filters to only PF locations and sorts them' do
        result = location.sort_and_filter_pick_ups
        expect(result).to eq([{ "label" => "Firestone Library, Microforms", "gfa_pickup" => "PF", "staff_only" => false }])
      end
    end

    context 'when location code is not firestone' do
      let(:location) { described_class.new({ "code" => "arch$stacks", "delivery_locations" => delivery_locations_with_pf }) }

      it 'rejects PF locations and sorts them' do
        result = location.sort_and_filter_pick_ups
        expected = [
          { "label" => "Architecture Library", "gfa_pickup" => "PW", "staff_only" => false },
          { "label" => "Firestone Library", "gfa_pickup" => "PA", "staff_only" => false },
          { "label" => "Lewis Library", "gfa_pickup" => "PN", "staff_only" => false },
          { "label" => "Technical Services HMT (Staff Only)", "gfa_pickup" => "QC", "staff_only" => true }
        ]
        expect(result).to eq(expected)
      end
    end
  end
end
