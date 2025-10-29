# frozen_string_literal: true
require 'rails_helper'

describe Requests::Form, vcr: { cassette_name: 'form_models', record: :none }, requests: true do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "REG",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:patron) do
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end
  let(:patron_request) do
    # Mocking Thread, because these tests deadlock if it is a real Thread
    instance_double(Thread, value: patron)
  end

  before { stub_delivery_locations }

  context "with a bad system_id" do
    let(:bad_system_id) { 'foo' }
    let(:params) do
      {
        system_id: bad_system_id,
        mfhd: nil,
        patron_request:
      }
    end
    let(:bad_request) { described_class.new(**params) }
    describe '#solr_doc' do
      it 'returns an empty document response without a valid system id' do
        expect(bad_request.solr_doc(bad_system_id).empty?).to be true
      end
    end
  end

  context "a holding with multiple items, some of which are on reserve" do
    let(:user) { FactoryBot.create(:user) }

    before do
      stub_single_holding_location('engineer$stacks')
      stub_single_holding_location('engineer$res')
      stub_availability_by_holding_id(bib_id: '9960102253506421', holding_id: '22548491940006421')
      stub_catalog_raw(bib_id: '9960102253506421')
    end
    let(:params) do
      {
        system_id: '9960102253506421',
        mfhd: '22548491940006421',
        patron_request:
      }
    end
    let(:request_with_reserve_items) { described_class.new(**params) }

    it 'returns one requestable item' do
      expect(request_with_reserve_items.items['22548491940006421'].size).to eq(4)
      expect(request_with_reserve_items.requestable.size).to eq(1)
    end
  end

  context "with a system_id and a mfhd that has a holding record with an attached item record" do
    let(:bad_system_id) { 'foo' }
    let(:params) do
      {
        system_id: '9988805493506421',
        mfhd: '22705318390006421',
        patron_request:
      }
    end
    let(:request_with_holding_item) { described_class.new(**params) }

    describe "#doc" do
      it "returns a solr document" do
        expect(request_with_holding_item.doc).to be_truthy
      end
    end

    describe '#solr_doc' do
      it 'returns hash with a valid system id' do
        expect(request_with_holding_item.solr_doc(request_with_holding_item.system_id)).to be_a(Hash)
      end
    end

    describe "#hidden_field_metadata" do
      it "returns a display title" do
        expect(request_with_holding_item.hidden_field_metadata[:title]).to eq(["Taming Manhattan : environmental battles in the antebellum city"])
      end

      it "returns a author display" do
        expect(request_with_holding_item.hidden_field_metadata[:author]).to eq(["McNeur, Catherine"])
      end

      it "returns a date display" do
        expect(request_with_holding_item.hidden_field_metadata[:date]).to eq(["2014"])
      end

      it "returns a single ISBN" do
        allow(request_with_holding_item).to receive(:doc).and_return({ "isbn_s" => ["123", "456"] })
        expect(request_with_holding_item.hidden_field_metadata[:isbn]).to eq(["123"])
      end
    end

    describe "#ctx" do
      it "produces an ILLiad flavored openurl" do
        expect(request_with_holding_item.ctx).to be_an_instance_of(OpenURL::ContextObject)
        expect(request_with_holding_item.ctx.to_hash).to include(
          "rft.au" => "McNeur, Catherine",
          "rft.btitle" => "Taming Manhattan : environmental battles in the antebellum city",
          "rft.date" => "2014",
          "rft.genre" => "book",
          "rft.isbn" => "9780674725096",
          "rft.pub" => "Cambridge, Massachusetts: Harvard University Press",
          "rft.title" => "Taming Manhattan : environmental battles in the antebellum city"
        )
      end
    end

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(request_with_holding_item.requestable).to be_truthy
        expect(request_with_holding_item.requestable.size).to eq(1)
        expect(request_with_holding_item.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "Contains a requestable object with a holding" do
        expect(request_with_holding_item.requestable[0].holding).to be_truthy
      end

      it "Contains a requestable object with an item" do
        expect(request_with_holding_item.requestable[0].item?).to be_truthy
      end

      it "has a mfhd" do
        expect(request_with_holding_item.requestable[0].holding.mfhd_id).to eq params[:mfhd]
        expect(request_with_holding_item.requestable[0].holding.holding_data).to be_truthy
      end

      it "has location data" do
        expect(request_with_holding_item.requestable[0].location).to be_truthy
      end
    end

    describe "#load_location" do
      it "provides the location of the data" do
        expect(request_with_holding_item.location[:code]).to eq('arch$stacks')
      end
    end

    describe "#system_id" do
      it "has a system id" do
        expect(request_with_holding_item.system_id).to be_truthy
        expect(request_with_holding_item.system_id).to eq('9988805493506421')
      end
    end

    describe '#user' do
      it 'returns a user object' do
        expect(request_with_holding_item.user.is_a?(User)).to be true
      end
    end
  end

  context "with a system_id and a mfhd that only has a holding record" do
    let(:params) do
      {
        system_id: '9917917633506421',
        mfhd: '22720740220006421',
        patron_request:
      }
    end
    let(:request_with_only_holding) { described_class.new(**params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_holding.requestable).to be_truthy
        expect(request_with_only_holding.requestable.size).to eq(1)
        expect(request_with_only_holding.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a mfhd" do
        expect(request_with_only_holding.requestable[0].holding.mfhd_id).to eq params[:mfhd]
        expect(request_with_only_holding.requestable[0].holding.holding_data).to be_truthy
      end

      it "has location data" do
        expect(request_with_only_holding.requestable[0].location).to be_truthy
      end
    end
  end

  context "with a system_id only that has holdings and item records" do
    let(:params) do
      {
        system_id: '994909303506421',
        mfhd: '22584686190006421',
        patron_request:
      }
    end

    let(:request_system_id_only_with_holdings_items) { described_class.new(**params) }

    before do
      stub_scsb_availability bib_id: '994909303506421', institution_id: 'PUL', barcode: '32101055804825'
    end

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings_items.requestable).to be_truthy
        expect(request_system_id_only_with_holdings_items.requestable.size).to eq(84)
        expect(request_system_id_only_with_holdings_items.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(request_system_id_only_with_holdings_items.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(request_system_id_only_with_holdings_items.holdings.size).to eq(2)
      end
    end
  end

  context "with a system_id that only has holdings records" do
    let(:params) do
      {
        system_id: '9947589763506421',
        mfhd: '22656885190006421',
        patron_request:
      }
    end
    let(:request_system_id_only_with_holdings) { described_class.new(**params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings.requestable).to be_truthy
        expect(request_system_id_only_with_holdings.requestable.size).to eq(1)
        expect(request_system_id_only_with_holdings.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(request_system_id_only_with_holdings.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(request_system_id_only_with_holdings.holdings.size).to eq(1)
      end
    end
  end

  context "with a system_id that has holdings records that do and don't have item records attached" do
    let(:params) do
      {
        system_id: '9924784993506421',
        mfhd: '22708132010006421',
        patron_request:
      }
    end
    let(:request_system_id_only_with_holdings_with_some_items) { described_class.new(**params) }

    before do
      stub_scsb_availability bib_id: '9924784993506421', institution_id: 'PUL', barcode: '32101105136228'
    end

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings_with_some_items.requestable).to be_truthy
        expect(request_system_id_only_with_holdings_with_some_items.requestable.size).to eq(1)
        expect(request_system_id_only_with_holdings_with_some_items.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has location data" do
        expect(request_system_id_only_with_holdings_with_some_items.requestable[0].location).to be_truthy
      end

      it "has a collection of mfhds" do
        expect(request_system_id_only_with_holdings_with_some_items.holdings.size).to eq(9)
      end
    end
  end

  context "A system id that has a holding with reserve items in a temporary location" do
    let(:params) do
      {
        system_id: '9931805453506421',
        mfhd: '22705623210006421',
        patron_request:
      }
    end
    let(:request_with_items_at_temp_locations) { described_class.new(**params) }

    describe "#requestable" do
      it "has an empty list of requestable objects" do
        expect(request_with_items_at_temp_locations.requestable).to be_truthy
        expect(request_with_items_at_temp_locations.requestable.size).to eq(0)
      end
    end
  end

  context "A system id that has a holding with item not in a temporary location" do
    let(:params) do
      {
        system_id: '9961959423506421',
        mfhd: '22525427880006421',
        patron_request:
      }
    end
    let(:request_with_items_at_temp_locations) { described_class.new(**params) }

    describe "#requestable" do
      it "has a list of requestable objects" do
        expect(request_with_items_at_temp_locations.requestable).to be_truthy
        expect(request_with_items_at_temp_locations.requestable.size).to eq(1)
        expect(request_with_items_at_temp_locations.requestable[0]).to be_instance_of(Requests::Requestable)
        expect(request_with_items_at_temp_locations.requestable.last.location_code).to eq('lewis$resterm')
      end
    end
  end

  context "a system_id with no holdings or items" do
    let(:params) do
      {
        system_id: '9923858683506421',
        mfhd: nil,
        patron_request:
      }
    end
    let(:request_with_only_system_id) { described_class.new(**params) }

    describe "#requestable" do
      it "does not have a list of request objects" do
        expect(request_with_only_system_id.requestable.empty?).to be true
      end
    end
  end

  context "when a recap with no items" do
    let(:params) do
      {
        system_id: '9947595913506421',
        mfhd: '22489764810006421',
        patron_request:
      }
    end
    let(:request_with_only_system_id) { described_class.new(**params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end
    end
  end

  context "When passed an ID for an On Order Title" do
    let(:params) do
      {
        system_id: '99103251433506421',
        mfhd: '22480270140006421',
        patron_request:
      }
    end
    let(:request_with_on_order) { described_class.new(**params) }
    let(:firestone_circ) do
      { label: "Firestone Library", gfa_pickup: "PA", pick_up_location_code: "firestone", staff_only: false }
    end
    let(:architecture) do
      { label: "Architecture Library", gfa_pickup: "PW", pick_up_location_code: "arch", staff_only: false }
    end
    let(:eastasian) do
      { label: "East Asian Library", gfa_pickup: "PL", pick_up_location_code: "eastasian", staff_only: false }
    end
    before { stub_single_holding_location 'firestone$stacks' }

    describe "#requestable" do
      it "has requestable items" do
        expect(request_with_on_order.requestable.size).to be >= 1
      end

      it "has a requestable with 'on order' service" do
        expect(request_with_on_order.requestable.last.services.include?('on_order')).to be_truthy
      end

      it "has a requestable on order item" do
        expect(request_with_on_order.requestable.last.alma_managed?).to eq(true)
      end

      it "provides a list of the default pick-up locations" do
        expect(request_with_on_order.default_pick_ups).to be_truthy
        expect(request_with_on_order.default_pick_ups).to be_an(Array)
        expect(request_with_on_order.default_pick_ups.size).to be > 1
        expect(request_with_on_order.default_pick_ups.include?(firestone_circ)).to be_truthy
      end

      it "lists locations in an alphabetical order" do
        expect(request_with_on_order.default_pick_ups[0]).to eq(architecture)
        expect(request_with_on_order.default_pick_ups[1]).to eq(eastasian)
      end
    end
  end

  context "When passed a mfhd with missing items" do
    let(:params) do
      {
        system_id: '9920022063506421',
        mfhd: '22560993150006421',
        patron_request:
      }
    end
    let(:request_with_missing) { described_class.new(**params) }
    before { stub_single_holding_location 'firestone$stacks' }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request_with_missing.requestable.size).to be >= 1
      end

      it "shows missing items as eligible for ill" do
        expect(request_with_missing.requestable[2].services.include?('ill')).to be_truthy
      end

      it "is enumerated" do
        expect(request_with_missing.requestable[2].enumerated?).to be true
      end
    end
  end

  context "When passed an Aeon ID" do
    let(:params) do
      {
        system_id: '9996272613506421',
        mfhd: '22529639530006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "shows item as aeon eligble" do
        expect(request.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "Holding with item in preservation and conservation" do
    let(:params) do
      {
        system_id: '9942430233506421',
        mfhd: '22600149340006421',
        patron_request:
      }
    end
    let(:request_preservation) { described_class.new(**params) }
    describe "#requestable" do
      it "shows items as eligible for illiad" do
        expect(request_preservation.requestable[1].services.include?('ill')).to be_truthy
      end
    end
  end

  context "Aeon item with holdings without items" do
    let(:params) do
      {
        system_id: '9917917633506421',
        mfhd: '22720740220006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }

    describe "#requestable" do
      it "has a requestable items" do
        expect(request.requestable.length).to eq(1)
      end

      it "does not have any item data" do
        expect(request.requestable.first.item).to be_nil
      end

      it "is eligible for aeon services" do
        expect(request.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "Aeon item with holdings without items with mfhd" do
    let(:params) do
      {
        system_id: '996160863506421',
        patron_request:,
        mfhd: '22563389780006421'
      }
    end
    let(:request) { described_class.new(**params) }

    describe "#requestable" do
      it "has a requestable items" do
        expect(request.requestable.length).to eq(7)
      end

      it "does have any item data" do
        expect(request.requestable.first.item).not_to be_nil
      end

      it "is eligible for aeon services" do
        expect(request.requestable.first.services.include?('aeon')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID" do
    let(:params) do
      {
        system_id: '9996764833506421',
        mfhd: '22680107620006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }

    describe "#requestable" do
      before do
        stub_scsb_availability(bib_id: "9996764833506421", institution_id: "PUL", barcode: '32101099103457')
      end

      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "is eligible for recap services with circulating items" do
        expect(request.requestable.first.services.include?('recap')).to be_truthy
        expect(request.requestable.first.scsb_in_library_use?).to be_falsey
      end

      it "is eligible for recap_edd services" do
        expect(request.requestable.first.services.include?('recap_edd')).to be_truthy
      end
    end
  end

  context "When Passed a ReCAP ID and mfhd for a serial at a non EDD location" do
    let(:params) do
      {
        system_id: '994264203506421',
        mfhd: '22697842050006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "is eligible for recap_edd services" do
        expect(request.requestable.last.services.include?('recap_edd')).to be_falsy
      end
    end

    describe '#serial?' do
      it 'returns true when the item is a serial' do
        expect(request.serial?).to be true
      end
    end
  end

  context 'When passed an item that is on the shelf' do
    let(:params) do
      {
        system_id: '9999074333506421',
        mfhd: '22578723910006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    before { stub_single_holding_location 'firestone$stacks' }

    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "is on the shelf" do
        expect(request.requestable.first.services.include?('on_shelf')).to be_truthy
      end

      it "is eligible for multiple services" do
        expect(request.requestable.first.services.size).to eq(2)
      end
    end
  end

  context 'When passed a holding with a null item record' do
    let(:params) do
      {
        system_id: '994955013506421',
        mfhd: '22644665360006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end
    end
  end

  context 'When passed a non-enumerated holdings with at least one loanable item' do
    let(:params) do
      {
        system_id: '9948152393506421',
        mfhd: '22717671090006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    before { stub_single_holding_location 'firestone$stacks' }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end
  end

  context 'Enumerated record with charged items' do
    let(:params) do
      {
        system_id: '994952203506421',
        mfhd: '22644769680006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end
  end

  context 'Enumerated record without charged items' do
    let(:params) do
      {
        system_id: '9974943583506421',
        mfhd: '22711798720006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    before do
      stub_request(:post, "https://scsb.recaplib.org:9093/sharedCollection/bibAvailabilityStatus")
        .and_return(status: 200, body: '[
        {
          "itemBarcode": "32101092034501",
          "itemAvailabilityStatus": "Available",
          "errorMessage": null,
          "collectionGroupDesignation": "Shared"
        },
        {
          "itemBarcode": "32101053324081",
          "itemAvailabilityStatus": "Available",
          "errorMessage": null,
          "collectionGroupDesignation": "Shared"
        },
        {
          "itemBarcode": "32101087922140",
          "itemAvailabilityStatus": "Available",
          "errorMessage": null,
          "collectionGroupDesignation": "Shared"
        },
        {
          "itemBarcode": "32101091639979",
          "itemAvailabilityStatus": "Available",
          "errorMessage": null,
          "collectionGroupDesignation": "Shared"
        }
      ]')
    end
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end
  end

  context 'Multi-holding record with charged items and items available at non-restricted locations' do
    let(:user) { FactoryBot.build(:user) }
    let(:params) do
      {
        system_id: '9925693243506421',
        mfhd: '22554332290006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    before { stub_single_holding_location 'firestone$stacks' }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end
  end

  context 'When a barcode only user visits the site' do
    let(:params) do
      {
        system_id: '994955013506421',
        mfhd: '22644665360006421',
        patron_request:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end
    end
  end

  context "When passed mfhd param" do
    let(:params) do
      {
        system_id: '9919698813506421',
        mfhd: '22589919750006421',
        patron_request:
      }
    end
    let(:request_with_optional_params) { described_class.new(**params) }

    describe "#request" do
      it "has accessible mfhd param" do
        expect(request_with_optional_params.mfhd).to eq('22589919750006421')
      end
    end
  end

  context "When passed an ID for a preservation office location" do
    let(:params) do
      {
        system_id: '9997123553506421',
        mfhd: '22586693240006421',
        patron_request:
      }
    end
    let(:request_for_preservation) { described_class.new(**params) }
    describe "#requestable" do
      it "has a preservation location code" do
        expect(request_for_preservation.requestable[0].location_code).to eq('firestone$pres')
      end
    end
  end

  context "When passed a system_id for a record with a single aeon holding" do
    let(:params) do
      {
        system_id: '9946931463506421',
        mfhd: '22715350280006421',
        patron_request:
      }
    end
    let(:request_with_single_aeon_holding) { described_class.new(**params) }
  end

  context "A SCSB id with a single holding" do
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-5290772',
        mfhd: nil,
        patron_request:
      }
    end
    let(:request_scsb) { described_class.new(**params) }
    before do
      stub_catalog_raw(bib_id: params[:system_id], type: 'scsb')
      stub_scsb_availability(bib_id: "5992543", institution_id: "CUL", barcode: 'CU11388110')
      stub_single_holding_location 'scsbcul'
    end
    describe '#requestable' do
      it 'has one requestable item' do
        expect(request_scsb.requestable.size).to eq(1)
      end
    end
    describe '#scsb_owning_institution' do
      it 'provides the SCSB owning institution ID' do
        expect(request_scsb.scsb_owning_institution(location_code)).to eq('CUL')
      end
    end
    describe '#recap_edd?' do
      it 'is request via EDD' do
        expect(request_scsb.requestable.first.recap_edd?).to be true
      end
    end
    describe '#available?' do
      it 'is available' do
        expect(request_scsb.requestable.first.available?).to be true
      end
    end
  end

  context "A SCSB id that does not allow edd" do
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-5640725',
        mfhd: nil,
        patron_request:
      }
    end
    let(:request_scsb) { described_class.new(**params) }
    before do
      stub_catalog_raw(bib_id: 'SCSB-5640725', type: 'scsb')
      stub_scsb_availability(bib_id: "9488888", institution_id: "CUL", barcode: 'MR00429228')
      stub_single_holding_location 'scsbcul'
    end
    describe '#requestable' do
      it 'has one requestable item' do
        expect(request_scsb.requestable.size).to eq(1)
      end
    end
    describe '#recap_edd?' do
      it 'is requestable via EDD' do
        expect(request_scsb.requestable.first.recap_edd?).to be false
      end
    end
    describe '#available?' do
      it 'is available' do
        expect(request_scsb.requestable.first.available?).to be true
      end
    end
  end

  context "A SCSB with an unknown format" do
    let(:location_code) { 'scsbnypl' }
    let(:params) do
      {
        system_id: 'SCSB-7935196',
        mfhd: nil,
        patron_request:
      }
    end
    let(:request_scsb) { described_class.new(**params) }
    before do
      stub_catalog_raw(bib_id: params[:system_id], type: 'scsb')
      stub_scsb_availability(bib_id: ".b106574619", institution_id: "NYPL", barcode: '33433088591924')
    end
    describe '#requestable' do
      it 'has an unknown format' do
        expect(request_scsb.ctx.referent.format).to eq('unknown')
      end
    end

    describe '#available?' do
      it 'is available' do
        expect(request_scsb.requestable.first.available?).to be true
      end
    end
  end

  context "SCSB manuscript with multiple volumes" do
    describe "#aeon_mapped_params" do
      let(:request_scsb_multi_volume_manuscript) { FactoryBot.build(:scsb_manuscript_multi_volume) }
      it "includes ItemVolume" do
        stub_catalog_raw(bib_id: 'SCSB-7874204', type: 'scsb')
        bibdata_availability_url = "#{Requests.config['bibdata_base']}/bibliographic/SCSB-7874204/holdings/8014468/availability.json"
        stub_request(:get, bibdata_availability_url)
          .to_return(status: 400)
        stub_single_holding_location 'scsbnypl'
        stub_scsb_availability bib_id: '.b195933230', institution_id: 'NYPL', barcode: '33433088494863'
        expect(request_scsb_multi_volume_manuscript.requestable[0].aeon_mapped_params.key?(:ItemVolume)).to be true
        expect(request_scsb_multi_volume_manuscript.requestable[0].aeon_mapped_params[:ItemVolume]).to eq('v. 2')
      end
    end
  end
end
