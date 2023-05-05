# frozen_string_literal: true
require 'rails_helper'

describe Requests::Request, vcr: { cassette_name: 'request_models', record: :none } do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:patron) do
    Requests::Patron.new(user:, session: {}, patron: valid_patron)
  end

  context "with a bad system_id" do
    let(:bad_system_id) { 'foo' }
    let(:params) do
      {
        system_id: bad_system_id,
        mfhd: nil,
        patron:
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
        source: 'pulsearch',
        mfhd: '22548491940006421',
        patron:
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
        patron:
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

    describe "#display_metadata" do
      it "returns a display title" do
        expect(request_with_holding_item.display_metadata[:title]).to be_truthy
      end

      it "returns a author display" do
        expect(request_with_holding_item.display_metadata[:author]).to be_truthy
      end
    end

    describe "#language" do
      it "returns a language_code" do
        expect(request_with_holding_item.language).to be_truthy
      end

      it "returns a language IANA code" do
        expect(request_with_holding_item.language).to eq 'en'
      end

      # Doesn't do this yet
      # it "returns two-character ISO 639-1 language code" do
      #   expect(request_with_holding_item.display_metadata[:author]).to be_truthy
      # end
    end

    describe "#ctx" do
      it "produces an ILLiad flavored openurl" do
        expect(request_with_holding_item.ctx).to be_an_instance_of(OpenURL::ContextObject)
      end
    end

    describe '#openurl_ctx_kev' do
      it 'returns an encoded query string' do
        expect(request_with_holding_item.openurl_ctx_kev).to be_a(String)
        request_with_holding_item.ctx.referent.identifiers.each do |identifier|
          expect(request_with_holding_item.openurl_ctx_kev).to include(CGI.escape(identifier))
        end
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
        expect(request_with_holding_item.requestable[0].holding).to be_truthy
        expect(request_with_holding_item.requestable[0].holding.key?(params[:mfhd])).to be_truthy
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

    describe "#thesis?" do
      it "does not identify itself as a thesis request" do
        expect(request_with_holding_item.thesis?).to be_falsy
      end
    end

    describe "#numismatics?" do
      it "does not identify itself as a numismatics request" do
        expect(request_with_holding_item.numismatics?).to be_falsy
      end
    end
  end

  context "with a system_id and a mfhd that only has a holding record" do
    let(:params) do
      {
        system_id: '9917917633506421',
        mfhd: '22720740220006421',
        patron:
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
        expect(request_with_only_holding.requestable[0].holding).to be_truthy
        expect(request_with_only_holding.requestable[0].holding.key?(params[:mfhd])).to be_truthy
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
        patron:
      }
    end

    let(:request_system_id_only_with_holdings_items) { described_class.new(**params) }

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_system_id_only_with_holdings_items.requestable).to be_truthy
        expect(request_system_id_only_with_holdings_items.requestable.size).to eq(84)
        expect(request_system_id_only_with_holdings_items.any_pageable?).to be(false)
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
        patron:
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
        patron:
      }
    end
    let(:request_system_id_only_with_holdings_with_some_items) { described_class.new(**params) }

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

  # on reserve flag = N in the availability response, should be Y
  # https://bibdata-alma-staging.princeton.edu/bibliographic/9931973043506421/holdings/22185253590006421/availability.json
  # https://github.com/pulibrary/bibdata/issues/1363
  context "A system id that has a holding with item on reserve" do
    let(:params) do
      {
        system_id: '9931973043506421',
        mfhd: '22185253590006421',
        patron:
      }
    end
    let(:request_with_items_on_reserve) { described_class.new(**params) }

    describe "#requestable" do
      it "is on reserve" do
        pending "https://github.com/pulibrary/bibdata/issues/1363"
        expect(request_with_items_on_reserve.requestable.first.on_reserve?).to be_truthy
      end
    end
  end

  context "A system id that has a holding with reserve items in a temporary location" do
    let(:params) do
      {
        system_id: '9931805453506421',
        mfhd: '22705623210006421',
        patron:
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
        patron:
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
        patron:
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
        patron:
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

    describe "#thesis?" do
      it "identifies itself as a thesis request" do
        expect(request_with_only_system_id.thesis?).to be_falsey
      end
    end
  end

  context "When passed a system_id for a theses record" do
    let(:params) do
      {
        system_id: 'dsp01rr1720547',
        mfhd: 'thesis',
        patron:
      }
    end
    let(:request_with_only_system_id) { described_class.new(**params) }

    before do
      stub_catalog_raw(bib_id: 'dsp01rr1720547', type: 'theses_and_dissertations')
    end

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a thesis holding location" do
        # todo- mudd location code does not exists in bibdata, but is being passed back by the index
        expect(request_with_only_system_id.requestable[0].holding.key?('thesis')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location.key?('code')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location_code).to eq 'mudd$stacks'
        expect(request_with_only_system_id.requestable[0].alma_managed?).to be_falsey
      end
    end

    describe "#thesis?" do
      it "identifies itself as a thesis request" do
        expect(request_with_only_system_id.thesis?).to be_truthy
      end
    end

    describe "#aeon_mapped_params" do
      it 'includes a Site param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Site)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Site]).to eq('MUDD')
      end

      it 'shouuld have an Aeon Form Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Form)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'shouuld have an Aeon Action Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Action)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'has a genre param set to thesis' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:genre)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:genre]).to eq('thesis')
      end
    end
  end

  context "When passed a system_id for a numismatics record" do
    let(:params) do
      {
        system_id: 'coin-1167',
        mfhd: 'numismatics',
        patron:
      }
    end
    let(:request_with_only_system_id) { described_class.new(**params) }

    before do
      stub_catalog_raw(bib_id: 'coin-1167', type: 'numismatics')
    end

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a numismatics holding location" do
        expect(request_with_only_system_id.requestable[0].holding.key?('numismatics')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location.key?('code')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location_code).to eq 'rare$num'
        expect(request_with_only_system_id.requestable[0].alma_managed?).to be_falsey
      end
    end

    describe "#numismatics?" do
      it "identifies itself as a numismatics request" do
        expect(request_with_only_system_id.numismatics?).to be_truthy
      end
    end

    describe "#aeon_mapped_params" do
      it 'includes a Site param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Site)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it 'has an Aeon Form Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Form)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'has an Aeon Action Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Action)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'has a genre param set to numismatics' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:genre)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:genre]).to eq('numismatics')
      end
    end
  end

  context "When passed a system_id for a numismatics record without a mfhd" do
    let(:params) do
      {
        system_id: 'coin-1167',
        mfhd: nil,
        patron:
      }
    end
    let(:request_with_only_system_id) { described_class.new(**params) }

    before do
      stub_catalog_raw(bib_id: 'coin-1167', type: 'numismatics')
    end

    describe "#requestable" do
      it "has a list of request objects" do
        expect(request_with_only_system_id.requestable).to be_truthy
        expect(request_with_only_system_id.requestable.size).to eq(1)
        expect(request_with_only_system_id.requestable[0]).to be_instance_of(Requests::Requestable)
      end

      it "has a numismatics holding location" do
        expect(request_with_only_system_id.requestable[0].holding.key?('numismatics')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location.key?('code')).to be_truthy
        expect(request_with_only_system_id.requestable[0].location_code).to eq 'rare$num'
        expect(request_with_only_system_id.requestable[0].alma_managed?).to be_falsey
      end
    end

    describe "#aeon_mapped_params" do
      it 'includes a Site param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Site)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Site]).to eq('RBSC')
      end

      it 'has an Aeon Form Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Form)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Form]).to eq('21')
      end

      it 'should have an Aeon Action Param' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:Action)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:Action]).to eq('10')
      end

      it 'has a genre param set to numismatics' do
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params.key?(:genre)).to be true
        expect(request_with_only_system_id.requestable[0].aeon_mapped_params[:genre]).to eq('numismatics')
      end
    end
  end

  context "When passed an ID for a paging location in nec outside of call number range" do
    let(:params) do
      {
        system_id: '9929370033506421',
        mfhd: '22539090210006421',
        patron:
      }
    end
    let(:request_at_paging_outside) { described_class.new(**params) }

    describe "#requestable" do
      it "is unavailable" do
        expect(request_at_paging_outside.requestable[0].location_code).to eq('firestone$nec')
        expect(request_at_paging_outside.any_pageable?).to be(false)
        expect(request_at_paging_outside.requestable[0].pageable?).to be_nil
      end
    end
  end

  # context "When passed an ID for a paging location in nec  within a paging call number range" do
  #   let(:params) {
  #     {
  #       system_id: '2942771',
  #       patron: patron,
  #     }
  #   }
  #   let(:request_at_paging_nec_multiple) { described_class.new(params) }
  #

  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(request_at_paging_nec_multiple.requestable[0].location_code).to eq('nec')
  #       expect(request_at_paging_nec_multiple.requestable[0].pageable?).to eq(true)
  #     end
  #   end

  #   describe "#any_pageable?" do
  #     it "should return true when all requestable items are pageable?" do
  #       expect(request_at_paging_nec_multiple.any_pageable?).to be_truthy
  #     end

  #     it "should return true when only some of the requestable items are pageable?" do
  #       request_at_paging_nec_multiple.requestable.first.item["status"] = 'Charged'
  #       expect(request_at_paging_nec_multiple.any_pageable?).to be_truthy
  #     end

  #     it "should return false when all requestable items are not pageable?" do
  #       request_at_paging_nec_multiple.requestable.each do |requestable|
  #         requestable.item["status"] = 'Charged'
  #         requestable.services = []
  #       end
  #       expect(request_at_paging_nec_multiple.any_pageable?).to be_falsy
  #     end
  #   end
  # end

  context "When passed an ID for a paging location in f outside of call number range" do
    let(:params) do
      {
        system_id: '9943404133506421',
        mfhd: '22514049930006421',
        patron:
      }
    end
    let(:request_at_paging_f) { described_class.new(**params) }

    describe "#pageable?" do
      it "is be false" do
        expect(request_at_paging_f.requestable[0].location_code).to eq('recap$pa')
        expect(request_at_paging_f.requestable[0].charged?).to be true
        expect(request_at_paging_f.requestable[0].pageable?).to be false
      end
    end
  end
  # 6009363 returned
  # context "When passed an ID for a paging location f within a call in a range" do
  #   let(:user) { FactoryBot.build(:user) }
  #   let(:params) {
  #     {
  #       system_id: '6009363',
  #       user: user
  #     }
  #   }
  #   let(:request_at_paging_f) { described_class.new(params) }
  #
  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(request_at_paging_f.any_pageable?).to be(true)
  #       expect(request_at_paging_f.requestable[0].location_code).to eq('f')
  #       expect(request_at_paging_f.requestable[0].pageable?).to eq(true)
  #       expect(request_at_paging_f.requestable[0].pick_up_locations.size).to eq(1)
  #     end
  #   end
  # end

  # from the A range in "f"
  context "When passed an ID for a paging location f outside of call number range" do
    let(:params) do
      {
        system_id: '9995457263506421',
        mfhd: '22560953240006421',
        patron:
      }
    end
    let(:request_at_paging_f) { described_class.new(**params) }

    describe "#requestable" do
      it "is unavailable" do
        expect(request_at_paging_f.requestable[0].location_code).to eq('firestone$stacks')
        expect(request_at_paging_f.requestable[0].pageable?).to eq(nil)
        expect(request_at_paging_f.any_pageable?).to be(false)
        expect(request_at_paging_f.requestable[0].alma_managed?).to eq(true)
      end
    end
  end

  # context "When passed an ID for an xl paging location" do
  #   let(:params) {
  #     {
  #       system_id: '9596359',
  #       patron: patron,
  #     }
  #   }
  #   let(:request_at_paging_f) { described_class.new(params) }
  #
  #   describe "#requestable" do
  #     it "should be unavailable" do
  #       expect(request_at_paging_f.requestable[0].location_code).to eq('xl')
  #       expect(request_at_paging_f.requestable[0].pageable?).to eq(true)
  #       expect(request_at_paging_f.any_pageable?).to be(true)
  #       expect(request_at_paging_f.requestable[0].alma_managed?).to eq(true)
  #     end
  #   end
  # end

  context "When passed an ID for an On Order Title" do
    let(:params) do
      {
        system_id: '99103251433506421',
        mfhd: '22480270140006421',
        patron:
      }
    end
    let(:request_with_on_order) { described_class.new(**params) }
    let(:firestone_circ) do
      { label: "Firestone Library", gfa_pickup: "PA", pick_up_location_code: "firestone", staff_only: false }
    end
    let(:architecture) do
      { label: "Architecture Library", gfa_pickup: "PW", pick_up_location_code: "arch", staff_only: false }
    end

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
        # test that it is an array of hashes
        expect(request_with_on_order.default_pick_ups.size).to be > 1
        expect(request_with_on_order.default_pick_ups.include?(firestone_circ)).to be_truthy
      end

      it "lists Firestone as the first choice" do
        expect(request_with_on_order.default_pick_ups.first).to eq(firestone_circ)
      end

      it "alphas sort the pickups between Firestone and staff locations" do
        expect(request_with_on_order.default_pick_ups[1]).to eq(architecture)
      end
    end
  end

  # Oversize ID pageable
  # context "When passed an ID for an Item with that is Oversize" do
  #   let(:params) {
  #     {
  #       system_id: '3785401',
  #       patron: patron,
  #     }
  #   }
  #   let(:request_oversize) { described_class.new(params) }
  #

  #   describe "#requestable" do
  #     it "should have an requestable items" do
  #       expect(request_oversize.requestable.size).to be >= 1
  #     end

  #     it "should be in a location that contains some pageable items" do
  #       expect(request_oversize.requestable[0].location_code).to eq('f')
  #       expect(request_oversize.requestable[0].alma_managed?).to eq(true)
  #     end

  #     it "should be have pageable items" do
  #       expect(request_oversize.any_pageable?).to be(true)
  #     end

  #     it "should have a pageable item" do
  #       expect(request_oversize.requestable[0].pageable?).to eq(true)
  #     end
  #   end
  # end

  # Item with no call number 9602545
  context "When passed an ID for an Item in a pageable location that has no call number" do
    let(:params) do
      {
        system_id: '9996025453506421',
        mfhd: '22565008360006421',
        patron:
      }
    end
    let(:request_no_callnum) { described_class.new(**params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request_no_callnum.requestable.size).to be >= 1
      end

      it "is in a pageable location" do
        expect(request_no_callnum.requestable[0].location_code).to eq('firestone$stacks')
        expect(request_no_callnum.requestable[0].alma_managed?).to eq(true)
      end

      it "does not have any pageable items" do
        expect(request_no_callnum.any_pageable?).to be(false)
      end

      it "has a pageable item" do
        expect(request_no_callnum.requestable[0].pageable?).to be_nil
      end
    end
  end
  ## Add context for Visuals when available
  ## Add context for EAD when available
  # http://localhost:4000/requests/2002206?mfhd=2281830
  context "When passed a mfhd with missing items" do
    let(:params) do
      {
        system_id: '9920022063506421',
        mfhd: '22560993150006421',
        patron:
      }
    end
    let(:request_with_missing) { described_class.new(**params) }

    before do
      stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/32101026169985")
        .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"32101026169985\",\"status\":\"Item not Found\"}", headers: {})
      stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/32101026132058")
        .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"32101026132058\",\"status\":\"Item not Found\"}", headers: {})
      stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/32101025649177")
        .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"32101025649177\",\"status\":\"Item not Found\"}", headers: {})
      stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/32101025649169")
        .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"32101025649169\",\"status\":\"Item not Found\"}", headers: {})
      stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/32101026173334")
        .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"32101026173334\",\"status\":\"Item not Found\"}", headers: {})
    end
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
        patron:
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

    describe "#single_aeon_requestable?" do
      it "identifies itself as a single aeon requestable" do
        expect(request.single_aeon_requestable?).to be_truthy
      end
    end
  end

  context "Aeon item with holdings without items" do
    let(:params) do
      {
        system_id: '9917917633506421',
        mfhd: '22720740220006421',
        patron:
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

    describe "#single_aeon_requestable?" do
      it "identifies itself as a single aeon requestable" do
        expect(request.single_aeon_requestable?).to be_truthy
      end
    end
  end

  context "Aeon item with holdings without items with mfhd" do
    let(:params) do
      {
        system_id: '996160863506421',
        patron:,
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

    describe "#single_aeon_requestable?" do
      it "identifies itself as a single aeon requestable" do
        expect(request.single_aeon_requestable?).to be_falsey
      end
    end
  end

  context "When Passed a ReCAP ID" do
    let(:params) do
      {
        system_id: '9996764833506421',
        mfhd: '22680107620006421',
        patron:
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

      # TODO: Remove when campus has re-opened
      # it "is not eligible for recap services during campus closure" do
      #   expect(request.requestable.last.services.include?('recap')).to be_true
      # end

      # TODO: Activate test when campus has re-opened
      # it "is eligible for recap services with circulating items" do
      #   expect(request.requestable.first.services.include?('recap')).to be_truthy
      #   expect(request.requestable.first.scsb_in_library_use?).to be_falsey
      # end

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
        patron:
      }
    end
    let(:request) { described_class.new(**params) }

    describe "#requestable" do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      # TODO: Remove when campus has re-opened
      it "is not eligible for recap services during campus closure" do
        expect(request.requestable.last.services.include?('recap')).to be_falsy
      end

      # TODO: Activate test when campus has re-opened
      xit "should be eligible for recap services" do
        expect(request.requestable.last.services.include?('recap')).to be_truthy
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

  context 'When passed an item that is traceable and mappable' do
    let(:params) do
      {
        system_id: '9999074333506421',
        mfhd: '22578723910006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end

      it "is on the shelf" do
        expect(request.requestable.first.services.include?('on_shelf')).to be_truthy
      end

      # these tests are temporarily pending until trace feature is resolved
      # see https://github.com/pulibrary/requests/issues/164 for info

      it "is eligible for multiple services" do
        expect(request.requestable.first.services.size).to eq(2)
      end

      xit "should be eligible for trace services" do
        expect(request.requestable.first.services.include?('trace')).to be_truthy
        expect(request.requestable.first.traceable?).to be true
      end
    end
  end
  # 495501
  context 'When passed a holding with a null item record' do
    let(:params) do
      {
        system_id: '994955013506421',
        mfhd: '22644665360006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end
    end
  end

  # 9746776
  context 'When passed a holdings with mixed physical and online items' do
    let(:params) do
      {
        system_id: '9997467763506421',
        mfhd: '22597992220006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#requestable' do
      it "is all online" do
        expect(request.all_items_online?).to be false
      end
    end
  end

  # 4815239
  context 'When passed a non-enumerated holdings with at least one loanable item' do
    let(:params) do
      {
        system_id: '9948152393506421',
        mfhd: '22717671090006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
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
        patron:
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
        patron:
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

    describe '#any_enumerated?' do
      it 'is enumerated' do
        expect(request.any_enumerated?).to be true
      end
    end
  end

  context 'Multi-holding record with charged items and items available at non-restricted locations' do
    let(:user) { FactoryBot.build(:user) }
    let(:params) do
      {
        system_id: '9925693243506421',
        mfhd: '22554332290006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#any_loanable_copies?' do
      it "has available copy" do
        expect(request.any_loanable_copies?).to be true
      end
    end
  end

  # Since we don't load multiple holdings any longer I'm not sure this is a valid test scenario
  #
  # context 'Multi-holding record with charged items and items available at restricted locations' do
  #   let(:user) { FactoryBot.build(:user) }
  #   let(:params) do
  #     {
  #       system_id: '9996968113506421',
  #       mfhd: '22117193570006421',
  #       patron: patron
  #     }
  #   end
  #   let(:request) { described_class.new(params) }
  #   describe '#any_loanable_copies?' do
  #     it "has available copy" do
  #       expect(request.any_loanable_copies?).to be false
  #     end
  #   end
  # end

  ### Review this test
  context 'RBSC single Item with no isbn' do
    let(:user) { FactoryBot.build(:user) }
    let(:params) do
      {
        system_id: '9926312653506421',
        mfhd: '22692741390006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }

    describe '#isbn_numbers?' do
      it 'returns false when there are no isbns present' do
        expect(request.isbn_numbers?).to be false
      end
    end
  end

  context 'single missing item with isbn' do
    let(:user) { FactoryBot.build(:user) }
    let(:params) do
      {
        system_id: '9917887963506421',
        mfhd: '22503918400006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#isbn_numbers?' do
      it 'returns true when there are isbns present' do
        expect(request.isbn_numbers?).to be true
      end
    end
  end

  context 'When a barcode only user visits the site' do
    let(:params) do
      {
        system_id: '994955013506421',
        mfhd: '22644665360006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    describe '#requestable' do
      it "has an requestable items" do
        expect(request.requestable.size).to be >= 1
      end
    end
  end

  context "When passed mfhd and source params" do
    let(:params) do
      {
        system_id: '9919698813506421',
        mfhd: '22589919750006421',
        source: 'pulsearch',
        patron:
      }
    end
    let(:request_with_optional_params) { described_class.new(**params) }

    describe "#request" do
      it "has accessible mfhd param" do
        expect(request_with_optional_params.mfhd).to eq('22589919750006421')
      end

      it "has accessible source param" do
        expect(request_with_optional_params.source).to eq('pulsearch')
      end
    end
  end

  context "When passed an ID for a preservation office location" do
    let(:params) do
      {
        system_id: '9997123553506421',
        mfhd: '22586693240006421',
        patron:
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
        patron:
      }
    end
    let(:request_with_single_aeon_holding) { described_class.new(**params) }

    describe "#requestable" do
      describe "#single_aeon_requestable?" do
        it "identifies itself as a single aeon requestable" do
          expect(request_with_single_aeon_holding.single_aeon_requestable?).to be_truthy
        end
      end
    end
  end

  context "A SCSB id with a single holding" do
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-5290772',
        source: 'pulsearch',
        mfhd: nil,
        patron:
      }
    end
    let(:request_scsb) { described_class.new(**params) }
    before do
      stub_catalog_raw(bib_id: params[:system_id], type: 'scsb')
      stub_scsb_availability(bib_id: "5992543", institution_id: "CUL", barcode: 'CU11388110')
    end
    describe '#requestable' do
      it 'has one requestable item' do
        expect(request_scsb.requestable.size).to eq(1)
      end
    end
    describe '#other_id' do
      it 'provides an other id value' do
        expect(request_scsb.other_id).to eq('5992543')
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
        source: 'pulsearch',
        mfhd: nil,
        patron:
      }
    end
    let(:request_scsb) { described_class.new(**params) }
    before do
      stub_catalog_raw(bib_id: 'SCSB-5640725', type: 'scsb')
      stub_scsb_availability(bib_id: "9488888", institution_id: "CUL", barcode: 'MR00429228')
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
        source: 'pulsearch',
        mfhd: nil,
        patron:
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

  context "Marquand item in Clancy" do
    let(:valid_patron) do
      { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
        "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
        "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
    end
    let(:location_code) { 'scsbnypl' }
    let(:params) do
      {
        system_id: '9956200533506421',
        source: 'pulsearch',
        mfhd: '2219823460006421',
        patron:
      }
    end
    let(:request) { described_class.new(**params) }
    before do
      stub_catalog_raw(bib_id: '9956200533506421')
      stub_availability_by_holding_id(bib_id: params[:system_id], holding_id: params[:mfhd])
      stub_request(:get, "#{Requests::Config[:clancy_base]}/itemstatus/v1/32101068477817")
        .to_return(status: 200, body: "{\"success\":true,\"error\":\"\",\"barcode\":\"32101068477817\",\"status\":\"Item In at Rest\"}", headers: {})
    end
    describe '#requestable' do
      it 'has an unknown format' do
        requestable = request.requestable.first
        expect(requestable.circulates?).to be_falsey
        expect(requestable.services).to eq(['clancy_in_library', 'clancy_edd'])
      end
    end
  end
end
