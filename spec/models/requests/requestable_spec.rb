require 'rails_helper'

describe Requests::Requestable, vcr: { cassette_name: 'requestable', record: :none } do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => true, "campus_authorized_category" => "full",
      ldap: { netid: "foo", department: "Test", address: "Box 1234", telephone: nil, givenname: "Foo", surname: "Request",
              email: "foo@princeton.edu", status: "staff", pustatus: "stf", universityid: "9999999", title: nil } }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user: user, patron: valid_patron) }

  context "Is a bibliographic record on the shelf" do
    let(:request) { FactoryBot.build(:request_on_shelf, patron: patron) }
    let(:requestable) { request.requestable.last }
    let(:mfhd_id) { requestable.holding.first[0] }
    let(:call_number) { CGI.escape(requestable.holding[mfhd_id]['call_number']) }
    let(:location_code) { CGI.escape(requestable.holding[mfhd_id]['location_code']) }
    let(:stackmap_url) { requestable.map_url(mfhd_id) }

    describe '#services' do
      it 'has on shelf and digitization services' do
        expect(requestable.services).to contain_exactly("on_shelf", "on_shelf_edd")
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

    describe '#map_url' do
      it 'returns a stackmap url' do
        expect(stackmap_url).to include("#{requestable.bib[:id]}/stackmap?cn=#{call_number}&loc=#{location_code}")
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

    describe "#open_libraries" do
      it "has all the open libraries" do
        expect(requestable.open_libraries).to eq(["firestone", "annex", "marquand", "mendel", "stokes", "eastasian", "arch", "lewis", "engineer", "recap"])
      end
    end
  end

  context "Is a bibliographic record from the thesis collection" do
    let(:request) { FactoryBot.build(:request_thesis, patron: patron) }
    let(:requestable) { request.requestable.first }
    let(:holding_id) { "thesis" }

    before do
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/dsp019c67wp402/raw")
        .to_return(status: 200, body: fixture('/dsp019c67wp402.json'), headers: {})
    end

    describe "#thesis?" do
      it "returns true when record is a senior thesis" do
        expect(requestable.thesis?).to be_truthy
      end

      it "reports as a non Voyager aeon resource" do
        expect(requestable.aeon?).to be_truthy
      end

      it "returns a params list with an Aeon Site MUDD" do
        expect(requestable.aeon_mapped_params.key?(:Site)).to be_truthy
        expect(requestable.aeon_mapped_params[:Site]).to eq('MUDD')
      end

      it "includes a ReferenceNumber" do
        expect(requestable.aeon_mapped_params[:ReferenceNumber]).to eq(request.system_id)
      end

      it "includes a CallNumber" do
        expect(requestable.aeon_mapped_params[:CallNumber]).to be_truthy
        expect(requestable.aeon_mapped_params[:CallNumber]).to eq(requestable.bib[:call_number_display].first)
      end

      it "includes an ItemTitle for a senior thesis record" do
        expect(requestable.aeon_mapped_params[:ItemTitle]).to be_truthy
        expect(requestable.aeon_mapped_params[:ItemTitle]).to eq(requestable.bib[:title_display])
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Mudd Manuscript Library - Stacks')
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.pick_up_locations).to eq([{ "label" => "Mudd Manuscript Library", "address" => "65 Olden Street Princeton, NJ 08544", "phone_number" => "609-258-6345", "contact_email" => "mudd@princeton.edu", "gfa_pickup" => "PH", "staff_only" => false, "pickup_location" => false, "digital_location" => true, "library" => { "label" => "Mudd Manuscript Library", "code" => "mudd", "order" => 0 }, "pick_up_location_code" => "mudd" }])
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

  context "Is a bibliographic record from the numismatics collection" do
    let(:request) { FactoryBot.build(:request_numismatics, patron: patron) }
    let(:requestable) { request.requestable.first }
    let(:holding_id) { "numismatics" }

    before do
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/coin-1167/raw")
        .to_return(status: 200, body: fixture('/coin-1167.json'), headers: {})
    end

    describe "#numismatics?" do
      it "returns true when record is a senior thesis" do
        expect(requestable.numismatics?).to be_truthy
      end

      it "reports as a non Voyager aeon resource" do
        expect(requestable.aeon?).to be_truthy
      end

      it "returns a params list with an Aeon Site RBSC" do
        expect(requestable.aeon_mapped_params.key?(:Site)).to be_truthy
        expect(requestable.aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it "includes a ReferenceNumber" do
        expect(requestable.aeon_mapped_params[:ReferenceNumber]).to eq(request.system_id)
      end

      it "includes a CallNumber" do
        expect(requestable.aeon_mapped_params[:CallNumber]).to be_truthy
        expect(requestable.aeon_mapped_params[:CallNumber]).to eq(requestable.bib[:call_number_display].first)
      end

      it "includes an ItemTitle for a numismatics record" do
        expect(requestable.aeon_mapped_params[:ItemTitle]).to be_truthy
        expect(requestable.aeon_mapped_params[:ItemTitle]).to eq(requestable.bib[:title_display])
      end
    end

    describe '#location_label' do
      it 'has a location label' do
        expect(requestable.location_label).to eq('Special Collections - Numismatics Collection')
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

  context 'A requestable item with a missing status' do
    let(:request) { FactoryBot.build(:request_missing_item, patron: patron) }
    let(:requestable) { request.requestable }
    describe "#services" do
      it "returns an item status of missing" do
        expect(requestable.size).to eq(1)
        expect(requestable.first.services).to be_truthy
      end

      it 'is available via borrow direct' do
        expect(requestable.first.services.include?('bd')).to be_truthy
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
    let(:request) { FactoryBot.build(:request_serial_with_item_on_hold, patron: patron) }
    let(:requestable_on_hold) { request.requestable[0] }
    describe '#hold_request?' do
      it 'with a Hold Request status it should be on the hold shelf' do
        expect(requestable_on_hold.hold_request?).to be true
      end
    end

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

  context 'A requestable item eligible for borrow direct' do
    let(:request) { FactoryBot.build(:missing_item, patron: patron) }
    let(:requestable) { request.requestable }
    describe '#services' do
      it 'is missing' do
        expect(requestable.first.missing?).to be true
      end

      it 'is eligible for borrow direct' do
        expect(requestable.first.borrow_direct?).to be true
      end

      it 'is eligible for ill' do
        expect(requestable.first.ill_eligible?).to be true
      end

      describe '#location_label' do
        it 'has a location label' do
          expect(requestable.first.location_label).to eq('Lewis Library - Stacks')
        end
      end
    end

    describe '#pick_up_locations' do
      it 'has pickup locations' do
        expect(requestable.first.pick_up_locations).to eq([{ "label" => "Lewis Library", "address" => "Washington Road and Ivy Lane Princeton, NJ 08544", "phone_number" => "609-258-6004", "contact_email" => "lewislib@princeton.edu", "gfa_pickup" => "PN", "staff_only" => false, "pickup_location" => true, "digital_location" => true, "library" => { "code" => "lewis", "label" => "Lewis Library", "order" => 0 }, "pick_up_location_code" => "lewis" }])
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

  context 'A non circulating item' do
    let(:request) { FactoryBot.build(:mfhd_with_no_circ_and_circ_item, patron: patron) }
    let(:requestable) { request.requestable[12] }
    # let(:item) { barcode :"32101024595744", id: 282_632, location: "f", copy_number: 1, item_sequence_number: 14, status: "Not Charged", on_reserve: "N", item_type: "NoCirc", pickup_location_id: 299, pickup_location_code: "fcirc", enum: "vol.22", "chron": "1996", enum_display: "vol.22 (1996)", label: "Firestone Library" }
    let(:no_circ_item_id) { requestable.item['id'] }
    let(:no_circ_item_type) { requestable.item['item_type'] }
    let(:no_circ_pick_up_location_id) { requestable.item['pickup_location_id'] }
    let(:no_circ_pick_up_location_code) { requestable.item['pickup_location_code'] }

    # rubocop:disable RSpec/MultipleExpectations
    describe 'getters' do
      it 'gets values' do
        expect(requestable.item_data?).to be true
        expect(requestable.item_type_non_circulate?).to be true
        expect(requestable.pick_up_location_id).to eq 'firestone'
        expect(requestable.pick_up_location_code).to eq 'firestone'
        expect(requestable.enum_value).to eq 'vol.22'
        expect(requestable.cron_value).to eq '1996'
        expect(requestable.location_label).to eq('Firestone Library - Stacks')
      end
    end
  end
  # rubocop:enable RSpec/MultipleExpectations

  context 'A circulating item' do
    let(:request) { FactoryBot.build(:mfhd_with_no_circ_and_circ_item, patron: patron) }
    let(:requestable) { request.requestable[0] }
    # let(:item) {"barcode":"32101022548893","id":282628,"location":"f","copy_number":1,"item_sequence_number":10,"status":"Not Charged","on_reserve":"N","item_type":"Gen","pickup_location_id":299,"pickup_location_code":"fcirc","enum_display":"vol.18","chron":"1992","enum_display":"vol.18 (1992)","label":"Firestone Library"}
    let(:no_circ_item_id) { requestable.item['id'] }
    let(:no_circ_item_type) { requestable.item['item_type'] }
    let(:no_circ_pick_up_location_id) { requestable.item['pickup_location_id'] }
    let(:no_circ_pick_up_location_code) { requestable.item['pickup_location_code'] }

    describe '#item_type_circulate' do
      it 'returns the item type from alma' do
        expect(requestable.item_type_non_circulate?).to be false
        expect(requestable.pick_up_location_id).to eq 'firestone'
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
    let(:request) { FactoryBot.build(:aeon_eal_alma_item, patron: patron) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#services' do
      it 'is eligible for aeon services' do
        expect(requestable.services.include?('aeon')).to be true
      end
    end

    describe '#aeon_open_url' do
      it 'returns an openurl with a Call Number param' do
        expect(requestable.aeon_openurl(request.ctx)).to be_a(String)
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
    let(:request) { FactoryBot.build(:aeon_rbsc_enumerated, patron: patron) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding['22677203260006421'] } }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    describe '#aeon_open_url' do
      it 'returns an openurl with volume data' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.volume=#{CGI.escape(requestable.item[:enum_display])}")
      end

      it 'returns an openurl with issue data' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.issue=#{CGI.escape(requestable.item[:chron_display])}")
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

  context 'A requestable item from an Aeon EAL Holding with a nil barcode' do
    let(:request) { FactoryBot.build(:aeon_rbsc_alma_enumerated, patron: patron) }
    let(:requestable_holding) { request.requestable.select { |r| r.holding['22563389780006421'] } }
    let(:holding_id) { '22256352610006421' }
    let(:requestable) { requestable_holding.first } # assume only one requestable
    let(:enumeration) { 'v.7' }

    describe '#aeon_open_url' do
      it 'identifies as an aeon eligible alma mananaged item' do
        expect(requestable.aeon?).to be true
      end

      it 'returns an openurl with enumeration when available' do
        expect(requestable.aeon_openurl(request.ctx)).to include("rft.volume=#{CGI.escape(enumeration)}")
      end

      it 'returns an openurl with item id as a value for iteminfo5' do
        expect(requestable.aeon_openurl(request.ctx)).to include("iteminfo5=#{requestable.item[:id]}")
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

  context 'A requestable item from a RBSC holding without an item record' do
    let(:request) { FactoryBot.build(:aeon_no_item_record, patron: patron) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    describe '#barcode?' do
      it 'does not have a barcode' do
        expect(requestable.barcode?).to be false
      end
    end

    describe '#site' do
      it 'returns a RBSC site param' do
        expect(requestable.site).to eq('RBSC')
      end
    end

    describe '#aeon_openurl' do
      let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }

      ## no idea why these two don't match
      it 'includes basic metadata' do
        expect(aeon_ctx).to include('ctx_id=&ctx_enc=info%3Aofi%2Fenc%3AUTF-8&rft.genre=unknown&rft.title=Beethoven%27s+andante+cantabile+aus+dem+Trio+op.+97%2C+fu%CC%88r+orchester&rft.creator=Beethoven%2C+Ludwig+van&rft.aucorp=Leipzig%3A+Kahnt&rft.pub=Leipzig%3A+Kahnt&rft.format=musical+score&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Aunknown&rft_id=https%3A%2F%2Fbibdata.princeton.edu%2Fbibliographic%2F9925358453506421&rft_id=info%3Aoclcnum%2F25615303&rfr_id=info%3Asid%2Fcatalog.princeton.edu%3Agenerator&CallNumber=M1004.L6+B3&ItemInfo1=Reading+Room+Access+Only&Location=rare%24ex&ReferenceNumber=9925358453506421&Site=RBSC')
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
    let(:request) { FactoryBot.build(:aeon_marquand, patron: patron) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    describe '#site' do
      it 'returns a Marquand site param' do
        expect(requestable.site).to eq('MARQ')
        expect(requestable.can_be_delivered?).to be_falsey
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
    let(:requestable) { Requests::Requestable.new(bib: {}, holding: [{ 1 => { 'call_number_browse': 'blah' } }], location: location, patron: patron, item: item) }

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
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
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
    let(:request) { FactoryBot.build(:aeon_w_barcode, patron: patron) }
    let(:requestable) { request.requestable.first } # assume only one requestable
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
    describe '#barcode?' do
      it 'has a barcode' do
        expect(requestable.barcode?).to be true
        expect(requestable.barcode).to match(/^[0-9]+/)
      end
    end

    describe '#aeon_openurl' do
      it 'returns an OpenURL CTX Object' do
        expect(aeon_ctx).to be_a(String)
      end

      it 'includes an ItemNumber Param' do
        expect(aeon_ctx).to include(requestable.barcode)
      end

      it 'includes a Site Param' do
        expect(aeon_ctx).to include(requestable.site)
      end

      it 'includes a Genre Param' do
        expect(aeon_ctx).to include('rft.genre=book')
      end

      it 'includes a Call Number Param' do
        expect(aeon_ctx).to include('CallNumber')
      end
    end

    describe '#aeon_basic_params' do
      it 'includes a Site param' do
        expect(requestable.aeon_basic_params.key?(:Site)).to be true
        expect(requestable.aeon_basic_params[:Site]).to eq('RBSC')
      end

      it 'has a Reference NUmber' do
        expect(requestable.aeon_basic_params.key?(:ReferenceNumber)).to be true
        expect(requestable.aeon_basic_params[:ReferenceNumber]).to eq(requestable.bib[:id])
      end

      it 'has Location Param' do
        expect(requestable.aeon_basic_params.key?(:Location)).to be true
        expect(requestable.aeon_basic_params[:Location]).to eq(requestable.holding.first.last['location_code'])
      end
    end

    describe '#aeon_request_url' do
      it 'beings with Aeon GFA base' do
        expect(requestable.aeon_request_url(request.ctx)).to match(/^#{Requests::Config[:aeon_base]}/)
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
    let(:request) { FactoryBot.build(:request_no_items, patron: patron) }
    let(:requestable) { request.requestable.first } # assume only one requestable

    # rubocop:disable RSpec/MultipleExpectations
    describe 'requestable with no items ' do
      it 'does not have item data' do
        expect(requestable.item_data?).to be false
        expect(requestable.pick_up_location_id).to eq ""
        expect(requestable.pick_up_location_code).to eq ""
        expect(requestable.item_type).to eq ""
        expect(requestable.enum_value).to eq ""
        expect(requestable.cron_value).to eq ""
      end

      context "patron is not campus authorized" do
        let(:valid_patron) do
          { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
            "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
            "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => false, "campus_authorized_category" => "none" }.with_indifferent_access
        end

        it 'does not have item data' do
          expect(requestable.item_data?).to be false
          expect(requestable.pick_up_location_id).to eq ""
          expect(requestable.pick_up_location_code).to eq ""
          expect(requestable.item_type).to eq ""
          expect(requestable.enum_value).to eq ""
          expect(requestable.cron_value).to eq ""
        end
      end

      context "patron is not campus authorized but is COVID trained" do
        let(:valid_patron) do
          { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
            "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
            "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => false, "campus_authorized_category" => "trained" }.with_indifferent_access
        end

        it 'does not have item data' do
          expect(requestable.item_data?).to be false
          expect(requestable.pick_up_location_id).to eq ""
          expect(requestable.pick_up_location_code).to eq ""
          expect(requestable.item_type).to eq ""
          expect(requestable.enum_value).to eq ""
          expect(requestable.cron_value).to eq ""
        end
      end
    end
    # rubocop:enable RSpec/MultipleExpectations

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
    ##  We must therefore assume that a holding with no itesm is not available
    ## https://bibdata-alma-staging.princeton.edu/bibliographic/9944928463506421/holdings/22490610730006421/availability.json
    describe "#available?" do
      it "is not available" do
        expect(requestable).not_to be_available
      end
    end
  end

  context 'On Order materials' do
    let(:request) { FactoryBot.build(:request_on_order, patron: patron) }
    let(:requestable) { request.requestable.last } # serial records on order at the end

    describe 'with a status of on_order ' do
      it 'is on_order and requestable' do
        expect(requestable.on_order?).to be_truthy
      end
      context "patron is not campus authorized" do
        let(:valid_patron) do
          { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
            "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
            "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => false, "campus_authorized_category" => "none" }.with_indifferent_access
        end

        it 'is on_order and not requestable' do
          expect(requestable.on_order?).to be_truthy
        end
      end

      context "patron is not campus authorized but is trained" do
        let(:valid_patron) do
          { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
            "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
            "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => false, "campus_authorized_category" => "trained" }.with_indifferent_access
        end

        it 'is on_order and is requestable' do
          expect(requestable.on_order?).to be_truthy
        end
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
      { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
        "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => true, "campus_authorized_category" => "full" }.with_indifferent_access
    end
    let(:patron) do
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end
    let(:params) do
      {
        system_id: '9999998003506421',
        mfhd: '22480198860006421',
        patron: patron
      }
    end
    let(:request) { Requests::Request.new(params) }
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
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding['22739043950006421'] } }
    let(:requestable_charged) { requestable_holding.first }

    describe '# checked-out requestable' do
      # TODO: Remove when campus has re-opened
      it "does not have borrow direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have borrow direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be true
      end

      # TODO: Remove when campus has re-opened
      it "does not have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have ILL request service available" do
        expect(requestable_charged.services.include?('ill')).to be true
      end
    end

    describe '# missing requestable' do
      let(:request_missing) { FactoryBot.build(:request_missing_item) }
      let(:requestable_missing) { request_missing.requestable.first }

      # TODO: Remove when campus has re-opened
      it "does not have borrow direct request service available" do
        expect(requestable_missing.services.include?('bd')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have borrow direct request service available" do
        expect(requestable_missing.services.include?('bd')).to be true
      end

      # TODO: Remove when campus has re-opened
      it "does not have ILL request service available" do
        expect(requestable_missing.services.include?('ill')).to be false
      end

      # TODO: Activate test when campus has re-opened
      xit "should have ILL request service available" do
        expect(requestable_missing.services.include?('ill')).to be true
      end
    end

    let(:request_aeon_mudd) { FactoryBot.build(:aeon_mudd) }
    let(:requestable_aeon_mudd) { request_aeon_mudd.requestable.first }

    describe '# reading_room requestable' do
      it "has Aeon request service available" do
        expect(requestable_aeon_mudd.services.include?('aeon')).to be true
      end
    end

    # let(:request_paging) { FactoryBot.build(:request_paging_available) }
    # let(:requestable_paging) { request_paging.requestable.first }

    # describe '# paging requestable' do
    #   it "should have the Paging request service available" do
    #     expect(requestable_paging.services.include?('paging')).to be true
    #   end
    # end
  end

  context 'When a barcode only user visits the site' do
    let(:valid_patron) do
      { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
        "patron_id" => "99999", "active_email" => "foo@princeton.edu", "campus_authorized" => true }.with_indifferent_access
    end
    let(:patron) do
      Requests::Patron.new(user: user, session: {}, patron: valid_patron)
    end
    let(:params) do
      {
        system_id: '9999998003506421',
        mfhd: '22480198860006421',
        patron: patron
      }
    end
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '#requestable' do
      before do
        stub_scsb_availability(bib_id: "9999998003506421", institution_id: "PUL", barcode: '32101099186403')
      end

      # TODO: Activate test when campus has re-opened
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

    # let(:request_paging) { FactoryBot.build(:request_paging_available_barcode_patron) }
    # let(:requestable_paging) { request_paging.requestable.first }

    # describe '#paging requestable' do
    #   it "should have the Paging request service available" do
    #     expect(requestable_paging.services.include?('paging')).to be true
    #   end
    # end

    let(:request_charged) { FactoryBot.build(:request_with_items_charged_barcode_patron) }
    let(:requestable_holding) { request_charged.requestable.select { |r| r.holding['22739043950006421'] } }
    let(:requestable_charged) { requestable_holding.first }

    describe '#checked-out requestable' do
      # Barcode users should NOT have the following privileges ...

      it "does not have Borrow Direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

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
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/foo?ldap=true").to_return(status: 200, body: valid_patron_response, headers: {})
      Requests::Patron.new(user: user, session: {})
    end
    let(:params) do
      {
        system_id: '9999998003506421',
        mfhd: '22480198860006421',
        patron: patron
      }
    end
    let(:request) { Requests::Request.new(params) }
    let(:requestable) { request.requestable.first }

    describe '#recap requestable' do
      # TODO: Remove when campus has re-opened
      it "does not have recap request service available during campus closure" do
        expect(requestable.services.include?('recap')).to be false
      end
      # TODO: Activate test when campus has re-opened
      xit "should have recap request service available" do
        expect(requestable.services.include?('recap')).to be true
      end

      it "does not have recap edd request service available" do
        expect(requestable.services.include?('recap_edd')).to be false
      end
    end

    # describe '#paging-requestable' do
    #   let(:request_paging) { FactoryBot.build(:request_paging_available_unauthenticated_patron) }
    #   let(:requestable_paging) { request_paging.requestable.first }

    #   it "should have the Paging request service available" do
    #     expect(requestable_paging.services.include?('paging')).to be true
    #   end
    # end

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
      it "does not have Borrow Direct request service available" do
        expect(requestable_charged.services.include?('bd')).to be false
      end

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

    describe "#resource_shared?" do
      it 'is not resource shared' do
        expect(requestable).not_to be_resource_shared
      end
    end
  end
  context 'A requestable item from a RBSC holding creates an openurl with volume and call number info' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_aeon_holding_volume_note) }
    let(:requestable) { request.requestable.select { |m| m.holding.first.first == '22563389780006421' }.first }
    let(:aeon_ctx) { requestable.aeon_openurl(request.ctx) }
    describe '#aeon_openurl' do
      it 'includes the location_has note as the volume' do
        expect(aeon_ctx).to include('rft.volume=v.7')
      end

      it 'includes the call number of the holding' do
        expect(aeon_ctx).to include('CallNumber=2015-0801N')
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
  context 'A SCSB Item from a location with no pick-up restrictions' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_cu) }
    let(:requestable) { request.requestable.first }
    describe '#pick_up_locations' do
      it 'has a single pick-up location' do
        stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-5235419/raw")
          .to_return(status: 200, body: fixture('/SCSB-5235419.json'), headers: {})
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=53360890")
          .to_return(status: 200, body: '[]')
        expect(requestable.pick_up_locations.size).to eq(1)
        expect(requestable.pick_up_locations.first[:gfa_pickup]).to eq('QX')
      end
    end

    # ETAS Status not relevant for Alma
    # describe '#etas_limited_access' do
    #   it 'is not restricted' do
    #     stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=53360890")
    #       .to_return(status: 200, body: '[]')
    #     expect(requestable.etas_limited_access). to be_falsey
    #   end
    # end
  end

  context 'A SCSB Item with no oclc number' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_no_oclc) }
    let(:requestable) { request.requestable.first }

    before do
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-5396104/raw")
        .to_return(status: 200, body: fixture('/SCSB-5396104.json'), headers: {})
    end

    describe '#etas_limited_access' do
      it 'is not restricted' do
        expect(requestable.etas_limited_access). to be_falsey
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

  context 'A SCSB Item from a location with a pick-up and in library use restriction' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_ar) }
    let(:requestable) { request.requestable.first }

    before do
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-2650865/raw")
        .to_return(status: 200, body: fixture('/SCSB-2650865.json'), headers: {})
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=29065769")
        .to_return(status: 200, body: '[]')
      stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
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
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-2901229/raw")
        .to_return(status: 200, body: fixture('/SCSB-2901229.json'), headers: {})
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=17322905")
        .to_return(status: 200, body: '[{"id":null,"oclc_number":"17322905","bibid":"1029088","status":"ALLOW","origin":"CUL"}, {"id":null,"oclc_number":"17322905","bibid":"1029088","status":"DENY","origin":"CUL"}]')
      stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
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

    describe "#resource_shared?" do
      it 'is not resource shared' do
        expect(requestable).not_to be_resource_shared
      end
    end
  end

  context 'An Item being shared with another institution' do
    let(:request) { Requests::Request.new(system_id: '9977664533506421', mfhd: '22109013720006421', patron: patron) }
    let(:requestable) { request.requestable.first }

    before do
      stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/9977664533506421/raw")
        .to_return(status: 200, body: fixture('/9977664533506421.json'), headers: {})
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/bibliographic/9977664533506421/holdings/22109013720006421/availability.json")
        .to_return(status: 200, body: '[{"barcode":"32101092097763","id":"23109013710006421","holding_id":"22109013720006421","copy_number":"1",'\
                                      '"status":"Not Available","status_label":"Resource Sharing Request","status_source":"process_type","process_type":"ILL","on_reserve":"N","item_type":"Gen","pickup_location_id":"RES_SHARE",'\
                                      '"pickup_location_code":"RES_SHARE","location":"RES_SHARE$OUT_RS_REQ","label":"ReCAP","description":"","enum_display":"","chron_display":"","in_temp_library":true,"temp_library_code":"RES_SHARE",'\
                                      '"temp_library_label":"Resource Sharing Library","temp_location_code":"RES_SHARE$OUT_RS_REQ","temp_location_label":"Resource Sharing Library"}]')
      stub_request(:get, "#{Requests::Config[:bibdata_base]}/locations/holding_locations/RES_SHARE$OUT_RS_REQ.json")
        .to_return(status: 200, body: '{"label":"Borrowing Resource Sharing Requests","code":"RES_SHARE$OUT_RS_REQ","aeon_location":false,"recap_electronic_delivery_location":false,"open":true,"requestable":true,"always_requestable":false,"circulates":true,'\
                                      '"remote_storage":"","library":{"label":"Resource Sharing Library","code":"RES_SHARE","order":0},"holding_library":null,"hours_location":null,"delivery_locations":[]}')
      stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
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

    describe "#resource_shared?" do
      it 'is resource shared' do
        expect(requestable).to be_resource_shared
      end
    end
  end

  context 'A ReCAP Harvard Item' do
    let(:user) { FactoryBot.build(:user) }
    let(:request) { FactoryBot.build(:request_scsb_hl) }
    let(:requestable) { request.requestable.first }
    describe '#pick_up_locations' do
      it 'has a single pick-up location' do
        stub_request(:get, "#{Requests::Config[:pulsearch_base]}/catalog/SCSB-10966202/raw")
          .to_return(status: 200, body: fixture('/SCSB-10966202.json'), headers: {})
        stub_request(:get, "#{Requests::Config[:bibdata_base]}/hathi/access?oclc=40820403")
          .to_return(status: 200, body: '[]')
        stub_scsb_availability(bib_id: "990081790140203941", institution_id: "HL", barcode: 'HXSS9U')
        expect(requestable.pick_up_locations.size).to eq(1)
        expect(requestable.pick_up_locations.first[:gfa_pickup]).to eq('QX')
        expect(requestable).to be_recap_edd
      end
    end
  end
end
