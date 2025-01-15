# frozen_string_literal: true
require 'rails_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable', record: :none }, requests: true do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "REG",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu",
      ldap: { netid: "foo", department: "Test", address: "Box 1234", telephone: nil, givenname: "Foo", surname: "Request",
              email: "foo@princeton.edu", status: "staff", pustatus: "stf", universityid: "9999999", title: nil } }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user:, patron_hash: valid_patron) }

  context "Is a bibliographic record on the shelf" do
    let(:request) { FactoryBot.build(:request_on_shelf, patron:) }
    let(:requestable) { request.requestable.last }
    let(:mfhd_id) { requestable.holding.mfhd_id }
    let(:call_number) { CGI.escape(requestable.holding.holding_data['call_number']) }
    let(:location_code) { CGI.escape(requestable.holding.holding_data['location_code']) }

    describe '#services' do
      it 'has on shelf and digitization services' do
        expect(requestable.services).to contain_exactly("on_shelf", "on_shelf_edd")
      end
    end

    describe '#replace_existing_services' do
      it 'provides an option for other classes to modify the list of services' do
        expect(requestable.services).to contain_exactly("on_shelf", "on_shelf_edd")

        requestable.replace_existing_services(['online'])

        expect(requestable.services).to contain_exactly("online")
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Firestone Library - Stacks')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Firestone Library", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "PA", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item with a missing status' do
    let(:request) { FactoryBot.build(:request_missing_item, patron:) }
    let(:requestable) { request.requestable }
    describe "#services" do
      it "returns an item status of missing" do
        expect(requestable.size).to eq(1)
        expect(requestable.first.services).to be_truthy
      end

      it 'is available via ILL' do
        expect(requestable.first.services.include?('ill')).to be_truthy
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.first.location_label).to eq('Lewis Library - Stacks')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.first.pick_up_locations).to eq([{ "label" => "Lewis Library", "address" => "Washington Road and Ivy Lane Princeton, NJ 08544", "phone_number" => "609-258-6004", "contact_email" => "lewislib@princeton.edu", "gfa_pickup" => "PN", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Lewis Library", "code" => "lewis", "order" => 0 }, "pick_up_location_code" => "lewis" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable.first).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is not available" do
        expect(requestable.first).not_to be_available
      end
    end
  end

  context 'A requestable item with hold_request status' do
    let(:request) { FactoryBot.build(:request_serial_with_item_on_hold, patron:) }
    let(:requestable_on_hold) { request.requestable[0] }

    describe '#services' do
      it 'is available for resource sharing' do
        expect(requestable_on_hold.services.include?('ill')).to be true
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable_on_hold.location_label).to eq('Firestone Library - Stacks')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable_on_hold.pick_up_locations).to eq([{ "label" => "Firestone Library", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "PA", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable_on_hold).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is not available" do
        expect(requestable_on_hold).not_to be_available
      end
    end
  end

  context 'A non circulating item' do
    let(:request) { FactoryBot.build(:mfhd_with_no_circ_and_circ_item, patron:) }
    let(:requestable) { request.requestable[12] }
    let(:no_circ_item_id) { requestable.item['id'] }
    let(:no_circ_item_type) { requestable.item['item_type'] }
    let(:no_circ_pick_up_location_code) { requestable.item['pickup_location_code'] }

    describe 'getters' do
      it 'gets values' do
        expect(requestable.item_data?).to be true
        expect(requestable.item_type_non_circulate?).to be true
        expect(requestable.pick_up_location_code).to eq 'firestone'
        expect(requestable.enum_value).to eq 'vol.22'
        expect(requestable.cron_value).to eq '1996'
        expect(requestable.location_label).to eq('Firestone Library - Stacks')
      end
    end
  end
  context 'A circulating item' do
    let(:request) { FactoryBot.build(:mfhd_with_no_circ_and_circ_item, patron:) }
    let(:requestable) { request.requestable[0] }
    let(:no_circ_item_id) { requestable.item['id'] }
    let(:no_circ_item_type) { requestable.item['item_type'] }
    let(:no_circ_pick_up_location_code) { requestable.item['pickup_location_code'] }

    describe '#item_type_circulate' do
      it 'returns the item type from alma' do
        expect(requestable.item_type_non_circulate?).to be false
        expect(requestable.pick_up_location_code).to eq 'firestone'
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Firestone Library - Stacks')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Firestone Library", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "fstcirc@princeton.edu", "gfa_pickup" => "PA", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item from an Aeon EAL Holding with a nil barcode' do
    let(:request) { FactoryBot.build(:aeon_eal_alma_item, patron:) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#services' do
      it 'is eligible for aeon services' do
        expect(requestable.services.include?('aeon')).to be true
      end
    end

    describe '#barcode' do
      it 'does not report there is a barocode' do
        expect(requestable.barcode?).to be false
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - East Asian Library (Gest) Rare Books')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "East Asian Library", "address" => "Frist Campus Center, Room 317 Princeton, NJ 08544", "phone_number" => "609-258-3182", "contact_email" => "gestcirc@princeton.edu", "gfa_pickup" => "PL", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "East Asian Library", "code" => "eastasian", "order" => 0 }, "pick_up_location_code" => "eastasian" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable serial item that has volume and item data in its openurl' do
    let(:request) { FactoryBot.build(:aeon_rbsc_enumerated, patron:) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding.mfhd_id == '22677203260006421' } }
    let(:requestable) { requestable_holding.first } # assume only one requestable

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Remote Storage (ReCAP): Rare Books. Special Collections Use Only')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Special Collections", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "rbsc@princeton.edu", "gfa_pickup" => "PG", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item from an Aeon EAL Holding with a nil barcode' do
    let(:request) { FactoryBot.build(:aeon_rbsc_alma_enumerated, patron:) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding.mfhd_id == '22563389780006421' } }
    let(:holding_id) { '22256352610006421' }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    let(:enumeration) { 'v.7' }

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Rare Books')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Special Collections", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "rbsc@princeton.edu", "gfa_pickup" => "PG", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item from a RBSC holding without an item record' do
    let(:request) { FactoryBot.build(:aeon_no_item_record, patron:) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    describe '#barcode?' do
      it 'does not have a barcode' do
        expect(requestable.barcode?).to be false
      end
    end

    describe '#site' do
      it 'returns a FIRE site param' do
        expect(requestable.site).to eq('FIRE')
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Rare Books')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Special Collections", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "rbsc@princeton.edu", "gfa_pickup" => "PG", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A MUDD holding' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:aeon_mudd) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'returns a RBSC site param' do
        expect(requestable.site).to eq('MUDD')
      end
    end
  end

  context 'A Recap Marquand holding' do
    let(:request) { FactoryBot.build(:aeon_marquand, patron:) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'returns a Marquand site param' do
        expect(requestable.site).to eq('MARQ')
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Marquand Library - Remote Storage (ReCAP): Marquand Library Use Only')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Marquand Library of Art and Archaeology", "address" => "McCormick Hall Princeton, NJ 08544", "phone_number" => "609-258-5863", "contact_email" => "marquand@princeton.edu", "gfa_pickup" => "PJ", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "label" => "Marquand Library", "code" => "marquand", "order" => 0 }, "pick_up_location_code" => "marquand" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A Non-Recap Marquand holding' do
    let(:valid_patron_response) { '{"netid":"foo","first_name":"Foo","last_name":"Request","barcode":"22101007797777","university_id":"9999999","patron_group":"staff","patron_id":"99999","active_email":"foo@princeton.edu"}' }
    let(:user) { FactoryBot.build(:user) }
    let(:item) { { status_label: "Available", location_code: "scsbnypl" }.with_indifferent_access }
    let(:location) { { "holding_library" => { "code" => "marquand" }, "library" => { "code" => "marquand" } } }
    let(:requestable) { described_class.new(bib: {}, holding: Requests::Holding.new(mfhd_id: 1, holding_data: { 'call_number_browse': 'blah' }), location:, patron:, item:) }

    describe '#site' do
      it 'returns a Marquand site param' do
        expect(requestable.holding_library_in_library_only?).to be_truthy
      end
    end

    describe "#held_at_marquand_library?" do
      it "is marquand" do
        expect(requestable).to be_held_at_marquand_library
      end
    end

    describe "#marquand_item?" do
      it 'is a marquand_item' do
        expect(requestable).to be_marquand_item
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item from a RBSC holding that has a long title' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:aeon_w_long_title) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    describe '#aeon_basic_params' do
      it 'includes a Title Param that is less than 250 characters' do
        expect(requestable.aeon_mapped_params.key?(:ItemTitle)).to be true
        expect(requestable.aeon_mapped_params[:ItemTitle].length).to be <= 250
      end
    end
    describe '#ctx' do
      it 'truncates the open url ctx title' do
        expect(request.ctx.referent.metadata['btitle'].length).to be <= 250
        expect(request.ctx.referent.metadata['title'].length).to be <= 250
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Rare Books Oversize')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to be_nil
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item from a RBSC holding with an item record including a barcode' do
    let(:request) { FactoryBot.build(:aeon_w_barcode, patron:) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    describe '#barcode?' do
      it 'has a barcode' do
        expect(requestable.barcode?).to be true
        expect(requestable.barcode).to match(/^[0-9]+/)
      end
    end

    describe '#aeon_basic_params' do
      it 'includes a Site param' do
        expect(requestable.aeon_basic_params.key?(:Site)).to be true
        expect(requestable.aeon_basic_params[:Site]).to eq('FIRE')
      end

      it 'has a Reference NUmber' do
        expect(requestable.aeon_basic_params.key?(:ReferenceNumber)).to be true
        expect(requestable.aeon_basic_params[:ReferenceNumber]).to eq(requestable.bib[:id])
      end

      it 'has Location Param' do
        expect(requestable.aeon_basic_params.key?(:Location)).to be true
        expect(requestable.aeon_basic_params[:Location]).to eq(requestable.holding.holding_data['location_code'])
      end
    end

    describe '#aeon_request_url with new aeon base' do
      it 'beings with Aeon GFA base' do
        stub_holding_locations
        expect(requestable.aeon_request_url).to match(/^#{Requests.config[:aeon_base]}/)
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Remote Storage (ReCAP): Rare Books. Special Collections Use Only')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Special Collections", "address" => "One Washington Rd. Princeton, NJ 08544", "phone_number" => "609-258-1470", "contact_email" => "rbsc@princeton.edu", "gfa_pickup" => "PG", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "library" => { "label" => "Firestone Library", "code" => "firestone", "order" => 0 }, "pick_up_location_code" => "firestone" }])
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end

  context 'A requestable item from Forrestal Annex with no item data' do
    let(:request) { FactoryBot.build(:request_no_items, patron:) }
    let(:requestable) { request.requestable.first }

    describe 'requestable with no items ' do
      it 'does not have item data' do
        expect(requestable.item_data?).to be false
        expect(requestable.pick_up_location_code).to eq ""
        expect(requestable.item_type).to eq ""
        expect(requestable.enum_value).to eq ""
        expect(requestable.cron_value).to eq ""
      end
    end
    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Forrestal Annex - Princeton Collection')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to be_nil
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    ## The JSON response for holding w/no items is empty now. We used to check the availability at the bib level, but that is not available in alma
    ##  We must therefore assume that a holding with no items is not available
    ## https://bibdata-alma-staging.princeton.edu/bibliographic/9944928463506421/holdings/22490610730006421/availability.json
    describe "#available?" do
      it "is not available" do
        expect(requestable).not_to be_available
      end
    end
  end

  context 'On Order materials' do
    let(:request) { FactoryBot.build(:request_on_order, patron:) }
    let(:requestable) { request.requestable.last } # serial records on order at the end

    describe 'with a status of on_order ' do
      it 'is on_order and requestable' do
        expect(requestable.on_order?).to be_truthy
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Firestone Library - Classics Collection')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to be_nil
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is not available" do
        expect(requestable).not_to be_available
      end
    end
  end

  # user authentication tests
  context 'When a princeton user with NetID visits the site' do
    let(:valid_patron) do
      { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "REG",
        "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
    end
    let(:patron) do
      Requests::Patron.new(user:, patron_hash: valid_patron)
    end
    let(:params) do
      {
        system_id: '9999998003506421',
        mfhd: '22480198860006421',
        patron:
      }
    end
    let(:request) { Requests::Form.new(**params) }
    let(:requestable) { request.requestable.first }

    describe '# offsite requestable' do
      before do
        stub_scsb_availability(bib_id: "9999998003506421", institution_id: "PUL", barcode: '32101099186403')
      end

      it "has recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "has recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be true
      end
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
      it "is available" do
        expect(requestable).to be_available
      end

      it "is recap" do
        expect(requestable).to be_recap
      end
    end

    let(:request_charged) { FactoryBot.build(:request_with_items_charged) }
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding.mfhd_id == '22739043950006421' } }
    let(:requestable_charged) { requestable_holding.first }

    describe '# checked-out requestable' do
      it "does not have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end
    end

    describe '# missing requestable' do
      let(:request_missing) { FactoryBot.build(:request_missing_item) }
      let(:requestable_missing) { request_missing.requestable.first }
    end

    let(:request_aeon_mudd) { FactoryBot.build(:aeon_mudd) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '# reading_room requestable' do
      it "has Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end
  end

  context 'When a barcode only user visits the site' do
    let(:valid_patron) do
      { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "REG",
        "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
    end
    let(:patron) do
      Requests::Patron.new(user:, patron_hash: valid_patron)
    end
    let(:params) do
      {
        system_id: '9999998003506421',
        mfhd: '22480198860006421',
        patron:
      }
    end
    let(:request) { Requests::Form.new(**params) }
    let(:requestable) { request.requestable.first }

    describe '#requestable' do
      before do
        stub_scsb_availability(bib_id: "9999998003506421", institution_id: "PUL", barcode: '32101099186403')
      end

      it "has recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end
      it "has recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be true
      end
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end

      describe "#available?" do
        it "is available" do
          expect(requestable).to be_available
        end
      end
    end

    let(:request_charged) { FactoryBot.build(:request_with_items_charged_barcode_patron) }
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding.mfhd_id == '22739043950006421' } }
    let(:requestable_charged) { requestable_holding.first }

    describe '#checked-out requestable' do
      # Barcode users should NOT have the following privileges

      it "does not have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end
    end

    let(:request_aeon_mudd) { FactoryBot.build(:aeon_mudd_barcode_patron) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '#reading room requestable' do
      it "has Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end
  end

  context 'When an access only user visits the site' do
    let(:user) { FactoryBot.build(:unauthenticated_patron) }
    let(:valid_patron_response) { '{"netid":"foo","first_name":"Foo","last_name":"Request","barcode":"22101007797777","university_id":"9999999","patron_group":"staff","patron_id":"99999","active_email":"foo@princeton.edu"}' }
    let(:patron) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true").to_return(status: 200, body: valid_patron_response, headers: {})
      Requests::Patron.new(user:)
    end
    let(:params) do
      {
        system_id: '9999998003506421',
        mfhd: '22480198860006421',
        patron:
      }
    end
    let(:request) { Requests::Form.new(**params) }
    let(:requestable) { request.requestable.first }

    describe '#recap requestable' do
      it "does not have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be false
      end
    end

    let(:request_aeon_mudd) { FactoryBot.build(:aeon_mudd_unauthenticated_patron) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '#reading room requestable' do
      it "has Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end

    # Barcode users should NOT have the following privileges ...
    let(:request_charged) { FactoryBot.build(:request_with_items_charged_unauthenticated_patron) }
    let(:requestable_charged) { request_charged.requestable.first }

    describe '#checked-out requestable' do
      it "does not have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end
    end

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable_charged).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is not available" do
        expect(requestable_charged).not_to be_available
      end
    end
  end
  context 'A requestable item from a RBSC holding creates an openurl with volume and call number info' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_aeon_holding_volume_note) }
    let(:requestable) { request.requestable.find { |m| m.holding.mfhd_id == '22563389780006421' } }

    describe "#held_at_marquand_library?" do
      it "is not marquand" do
        expect(requestable).not_to be_held_at_marquand_library
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end
  end
  context 'A SCSB Item from a location with no pick-up restrictions' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_cu) }
    let(:requestable) { request.requestable.first }
    describe '#pick_up_locations' do
      it 'has a single pick-up location' do
        stub_catalog_raw(bib_id: 'SCSB-5235419', type: 'scsb')
        expect(requestable.pick_up_locations.size).to eq(1)
        expect(requestable.pick_up_locations.first[:gfa_pickup]).to eq('QX')
      end
    end
  end

  context 'A SCSB Item from a location with a pick-up and in library use restriction' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_ar) }
    let(:requestable) { request.requestable.first }

    before do
      stub_catalog_raw(bib_id: 'SCSB-2650865', type: 'scsb')
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .to_return(status: 200, body: "[{\"itemBarcode\":\"AR65651294\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"}]")
    end

    describe '#pick_up_locations' do
      it 'has a single pick-up location' do
        expect(requestable.pick_up_locations.size).to eq(1)
        expect(requestable.pick_up_locations.first[:gfa_pickup]).to eq('PJ')
        expect(requestable.item["use_statement"]).to eq('In Library Use')
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end

    describe "#cul_avery?" do
      it 'is an Avery Item' do
        expect(requestable.cul_avery?).to be_truthy
      end
    end
  end

  context 'A SCSB Item from a location with a pick-up restrictions' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_mr) }
    let(:requestable) { request.requestable.first }

    before do
      stub_catalog_raw(bib_id: 'SCSB-2901229', type: 'scsb')
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .to_return(status: 200, body: "[{\"itemBarcode\":\"MR72802120\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"}]")
    end

    describe '#pick_up_locations' do
      it 'has a single pick-up location' do
        expect(requestable.pick_up_locations.size).to eq(1)
        expect(requestable.pick_up_locations.first[:gfa_pickup]).to eq('PK')
        expect(requestable.pick_up_locations.first[:label]).to eq('Mendel Music Library')
      end
    end

    describe "#available?" do
      it "is available" do
        expect(requestable).to be_available
      end
    end

    describe "#cul_music?" do
      it 'is an Music Library Item' do
        expect(requestable.cul_music?).to be_truthy
      end
    end
  end

  context 'An Item being shared with another institution' do
    let(:request) { Requests::Form.new(system_id: '9977664533506421', mfhd: '22109013720006421', patron:) }
    let(:requestable) { request.requestable.first }

    before do
      stub_catalog_raw(bib_id: '9977664533506421')
      stub_availability_by_holding_id(bib_id: '9977664533506421', holding_id: '22109013720006421')
      stub_single_holding_location('RES_SHARE$OUT_RS_REQ')
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .to_return(status: 200, body: "[{\"itemBarcode\":\"MR72802120\",\"itemAvailabilityStatus\":\"Available\",\"errorMessage\":null,\"collectionGroupDesignation\":\"Shared\"}]")
    end

    describe '#pick_up_locations' do
      it 'has no pick-up location' do
        expect(requestable.pick_up_locations).to be_blank
      end
    end

    describe "#available?" do
      it "is not available" do
        expect(requestable).not_to be_available
      end
    end

    describe "#cul_music?" do
      it 'is not an Music Library Item' do
        expect(requestable).not_to be_cul_music
      end
    end
  end

  context 'A ReCAP Harvard Item' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_hl) }
    let(:requestable) { request.requestable.first }
    describe '#pick_up_locations' do
      it 'has a single pick-up location' do
        stub_catalog_raw(bib_id: 'SCSB-10966202', type: 'scsb')
        stub_scsb_availability(bib_id: "990081790140203941", institution_id: "HL", barcode: 'HXSS9U')
        expect(requestable.pick_up_locations.size).to eq(1)
        expect(requestable.pick_up_locations.first[:gfa_pickup]).to eq('QX')
        expect(requestable).to be_recap_edd
      end
    end
  end

  context 'A Record in the Collection Development Office process type' do
    let(:request) { FactoryBot.build(:request_col_dev_office, patron:) }
    let(:requestable) { request.requestable.first }
    before do
      stub_catalog_raw(bib_id: '9911629773506421', type: 'alma')
      stub_availability_by_holding_id(bib_id: '9911629773506421', holding_id: '22608294270006421')
    end
    describe "#available?" do
      it "is not available" do
        expect(requestable).not_to be_available
      end
    end
    describe "available for ill" do
      it 'is available for ill' do
        expect(requestable.services.include?('ill')).to be_truthy
      end
    end
  end

  context 'A Record in the Holdings Managment process type' do
    let(:request) { FactoryBot.build(:request_holdings_management, patron:) }
    let(:requestable) { request.requestable.first }
    before do
      stub_catalog_raw(bib_id: '9925798443506421', type: 'alma')
      stub_availability_by_holding_id(bib_id: '9925798443506421', holding_id: '22733278430006421')
    end
    describe "#available?" do
      it "is not available" do
        expect(requestable).not_to be_available
      end
    end
    describe "available for ill" do
      it 'is available for ill' do
        expect(requestable.services.include?('ill')).to be_truthy
      end
    end
  end
end
