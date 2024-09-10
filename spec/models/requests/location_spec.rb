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
  describe '#sort_pick_ups' do
    let(:delivery_locations) {
      [{"label"=>"Technical Services 693", "address"=>"693 Alexander Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"catalogn@princeton.edu", "gfa_pickup"=>"QT", "staff_only"=>true, "pickup_location"=>true, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}, {"label"=>"Architecture Library", "address"=>"School of Architecture Building, Second Floor Princeton, NJ 08544", "phone_number"=>"609-258-3256", "contact_email"=>"ues@princeton.edu", "gfa_pickup"=>"PW", "staff_only"=>false, "pickup_location"=>true, "digital_location"=>true, "library"=>{"label"=>"Architecture Library", "code"=>"arch", "order"=>0}}, {"label"=>"Firestone Library, Resource Sharing", "address"=>"One Washington Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"fstcirc@princeton.edu", "gfa_pickup"=>"QA", "staff_only"=>true, "pickup_location"=>true, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}, {"label"=>"Technical Services HMT", "address"=>"One Washington Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"catalogn@princeton.edu", "gfa_pickup"=>"QC", "staff_only"=>true, "pickup_location"=>true, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}, {"label"=>"Preservation", "address"=>"One Washington Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"fstcirc@princeton.edu", "gfa_pickup"=>"QP", "staff_only"=>true, "pickup_location"=>false, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}]
    }
    let(:delivery_locations_sorted) {
      [{"label"=>"Architecture Library", "address"=>"School of Architecture Building, Second Floor Princeton, NJ 08544", "phone_number"=>"609-258-3256", "contact_email"=>"ues@princeton.edu", "gfa_pickup"=>"PW", "staff_only"=>false, "pickup_location"=>true, "digital_location"=>true, "library"=>{"label"=>"Architecture Library", "code"=>"arch", "order"=>0}}, {"label"=>"Firestone Library, Resource Sharing (Staff Only)", "address"=>"One Washington Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"fstcirc@princeton.edu", "gfa_pickup"=>"QA", "staff_only"=>true, "pickup_location"=>true, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}, {"label"=>"Preservation (Staff Only)", "address"=>"One Washington Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"fstcirc@princeton.edu", "gfa_pickup"=>"QP", "staff_only"=>true, "pickup_location"=>false, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}, {"label"=>"Technical Services 693 (Staff Only)", "address"=>"693 Alexander Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"catalogn@princeton.edu", "gfa_pickup"=>"QT", "staff_only"=>true, "pickup_location"=>true, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}, {"label"=>"Technical Services HMT (Staff Only)", "address"=>"One Washington Rd. Princeton, NJ 08544", "phone_number"=>"609-258-1470", "contact_email"=>"catalogn@princeton.edu", "gfa_pickup"=>"QC", "staff_only"=>true, "pickup_location"=>true, "digital_location"=>false, "library"=>{"label"=>"Firestone Library", "code"=>"firestone", "order"=>0}}]
    }
    let(:location) {described_class.new({delivery_locations: delivery_locations})}

    it "sorts the delivery locations" do
      expect(location.sort_pick_ups).to eq(delivery_locations_sorted)
    end
  end 
end
