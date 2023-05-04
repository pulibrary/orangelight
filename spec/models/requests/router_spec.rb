# frozen_string_literal: true
require 'rails_helper'

describe Requests::Router, vcr: { cassette_name: 'requests_router', record: :none } do
  context "A Princeton Community User has signed in" do
    let(:user) { FactoryBot.create(:user) }
    let(:valid_patron) { { "netid" => "foo" }.with_indifferent_access }
    let(:patron) do
      Requests::Patron.new(user:, session: {}, patron: valid_patron)
    end

    let(:scsb_single_holding_item) { fixture('/SCSB-2635660.json') }
    let(:location_code) { 'scsbcul' }
    let(:params) do
      {
        system_id: 'SCSB-2635660',
        mfhd: nil,
        source: 'CUL',
        patron:
      }
    end
    let(:scsb_availability_params) do
      {
        bibliographicId: "667075",
        institutionId: "CUL"
      }
    end
    let(:scsb_availability_response) { '[{"itemBarcode":"CU53020880","itemAvailabilityStatus":"Not Available","errorMessage":null}]' }
    let(:request_scsb) { Requests::Request.new(**params) }
    let(:requestable) { request_scsb.requestable.first }
    let(:router) { described_class.new(requestable:, user:) }

    describe "SCSB item that is charged" do
      before do
        stub_catalog_raw(bib_id: params[:system_id], type: 'scsb')
        stub_request(:post, "#{Requests::Config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
          .with(headers: { Accept: 'application/json', api_key: 'TESTME' }, body: scsb_availability_params)
          .to_return(status: 200, body: scsb_availability_response)
      end

      it "has ILL but not Recall as a request service option" do
        expect(router.calculate_services.include?('ill')).to be_truthy
      end
    end

    describe "Online Holding" do
      let(:params) { {} }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:router) { described_class.new(requestable, user) }
      xit "Returns an Online Link" do
        expect(router.services.key?(:full_text)).to be_truthy
      end
    end

    describe "Print Holding in RBSC without items" do
      let(:params) { { system_id: 4, holding_id: 5, item_id: 6, patron: } }
      let(:requestable) { Requests::Requestable.new(params) }
      let(:router) { described_class.new(requestable, user) }
      xit "Returns an Aeon Reading Room Link" do
        expect(router.services.key?(:aeon)).to be_truthy
      end
    end

    describe "calculate_services" do
      let(:item) { {} }
      let(:stubbed_questions) do
        { alma_managed?: true, online?: false, in_process?: false,
          charged?: false, on_order?: false, aeon?: false,
          preservation?: false, annex?: false,
          plasma?: false, lewis?: false, recap?: false, held_at_marquand_library?: false,
          item_data?: false, recap_edd?: false, pageable?: false, scsb_in_library_use?: false, item:,
          library_code: 'ABC', eligible_for_library_services?: true }
      end
      let(:requestable) { instance_double(Requests::Requestable, stubbed_questions) }

      context "online holding" do
        before do
          stubbed_questions[:online?] = true
        end
        it "returns online in the services" do
          expect(router.calculate_services).to eq(['online'])
        end
      end

      context "in process" do
        before do
          stubbed_questions[:in_process?] = true
        end
        it "returns in_process in the services" do
          expect(router.calculate_services).to eq(['in_process'])
        end
        context "unauthorized user" do
          let(:user) { FactoryBot.build(:unauthenticated_patron) }

          it "returns nothing in the services" do
            expect(router.calculate_services).to eq([])
          end
        end
      end

      context "on order" do
        before do
          stubbed_questions[:on_order?] = true
        end
        it "returns on_order in the services" do
          expect(router.calculate_services).to eq(['on_order'])
        end
        context "unauthorized user" do
          let(:user) { FactoryBot.build(:unauthenticated_patron) }

          it "returns nothing in the services" do
            expect(router.calculate_services).to eq([])
          end
        end
      end

      context "aeon" do
        before do
          stubbed_questions[:aeon?] = true
        end
        it "returns aeon in the services" do
          expect(router.calculate_services).to eq(['aeon'])
        end
      end

      context "annex" do
        before do
          stubbed_questions[:annex?] = true
        end
        it "returns annex in the services" do
          expect(router.calculate_services).to eq(['annex', 'on_shelf_edd'])
        end
      end

      context "lewis" do
        before do
          stubbed_questions[:lewis?] = true
          stubbed_questions[:recap_pf?] = false
        end
        it "retune on shelf & edd because lewis is a regular library" do
          stubbed_questions[:circulates?] = true
          expect(router.calculate_services).to eq(["on_shelf_edd", "on_shelf"])
        end

        it "retune on shelf edd because lewis is a regular library" do
          stubbed_questions[:circulates?] = false
          expect(router.calculate_services).to eq(["on_shelf_edd"])
        end
      end

      context "recap" do
        before do
          stubbed_questions[:recap?] = true
          stubbed_questions[:item_data?] = true
          stubbed_questions[:recap_edd?] = true
          stubbed_questions[:holding_library_in_library_only?] = false
          stubbed_questions[:ask_me?] = true
          stubbed_questions[:circulates?] = true
          stubbed_questions[:recap_pf?] = false
        end
        it "returns recap_edd in the services" do
          expect(router.calculate_services).to contain_exactly('recap_edd', 'recap')
        end
        context "unauthorized user" do
          let(:user) { FactoryBot.build(:unauthenticated_patron) }

          it "returns nothing in the services" do
            expect(router.calculate_services).to eq([])
          end
        end
        context "no items" do
          before do
            stubbed_questions[:item_data?] = false
          end
          it "returns recap_no_items in the services" do
            expect(router.calculate_services).to eq(['recap_no_items'])
          end
        end

        context "items in firestone$pf" do
          before do
            stubbed_questions[:recap_pf?] = true
          end
          it "returns recap_in_library in the services" do
            expect(router.calculate_services).to eq(['recap_in_library'])
          end
        end

        context "scsb_in_library" do
          before do
            stubbed_questions[:scsb_in_library_use?] = true
          end
          it "returns recap_in_library in the services" do
            expect(router.calculate_services).to eq(['recap_in_library'])
          end
        end

        context "scsb_in_library AR collection" do
          let(:item) { { collection_code: 'AR' } }
          before do
            stubbed_questions[:scsb_in_library_use?] = true
            stubbed_questions[:recap_edd?] = false
          end
          it "returns recap_in_library in the services" do
            expect(router.calculate_services).to eq(["recap_in_library"])
          end
        end

        context "scsb_in_library MR collection" do
          let(:item) { { collection_code: 'MR' } }
          before do
            stubbed_questions[:scsb_in_library_use?] = true
            stubbed_questions[:recap_edd?] = false
            stubbed_questions[:eligible_for_library_services?] = false
          end
          it "returns ask_me in the services" do
            expect(router.calculate_services).to eq(["ask_me"])
          end
        end

        context "scsb_in_library MR collection campus authorized" do
          let(:item) { { collection_code: 'MR' } }
          before do
            stubbed_questions[:scsb_in_library_use?] = true
            stubbed_questions[:recap_edd?] = false
          end
          it "returns recap in the services" do
            expect(router.calculate_services).to eq(["recap"])
          end
        end
      end

      context "ill enumerate item" do
        before do
          stubbed_questions[:charged?] = true
          stubbed_questions[:enumerated?] = true
        end
        it "returns ill in the services" do
          expect(router.calculate_services).to eq(["ill"])
        end
      end

      context "on_shelf" do
        before do
          stubbed_questions[:circulates?] = true
          stubbed_questions[:recap_pf?] = false
        end
        it "returns on_shelf in the services" do
          expect(router.calculate_services).to eq(['on_shelf_edd', 'on_shelf'])
        end
      end

      context "not alma managed or scsb" do
        before do
          stubbed_questions[:alma_managed?] = false
          stubbed_questions[:partner_holding?] = false
        end
        it "returns aeon in the services" do
          expect(router.calculate_services).to eq(['aeon'])
        end
      end
    end

    describe "Print Holding in ReCAP with item record and open pick-up locations" do
    end

    describe "Print Holding in ReCAP with item record and restricted pick-up locations" do
    end

    describe "Print Holding at ReCAP with charged item" do
    end

    describe "Print Holding at ReCAP with EDD eligible item" do
    end

    describe "Annex Holding without item" do
    end

    describe "Annex Holding with item" do
      it "has pick-up locations" do
      end
    end

    describe "Annex Holding with charged item" do
    end

    context "When an item is in a pageable location" do
      describe "It has a unavilable status" do
      end
    end

    context "When a firestone item" do
      describe "Open Holding with item" do
        xit "has a firestone locator link when a firestone item" do
          expect(router.services.key?(:onshelf)).to be_truthy
        end
      end
    end

    context "When a non-frestone item" do
      describe "Open Holding with item" do
        xit "has a stackmap link when a firestone item" do
          expect(router.services.key?(:onshelf)).to be_truthy
        end
      end
    end

    describe "Open Holding with charged item" do
    end

    describe "Open Holding without item" do
    end

    describe "Open Holding with Charged Item" do
    end

    describe "Thesis Collection Item" do
    end
  end

  # Fill in when we support guest authentication
  # context "An Access Patron has signed in" do
  #   let(:user) { FactoryBot.create(:valid_access_patron) }

  #   describe "Print Holding with Charged Item"
  #   end
  # end

  # context "The user has not authenticated but can self-identify as an access patron" do
  #   let(:user) { FactoryBot.create(:unauthenticated_patron) }

  #   describe "Print Holding with Charge Item" do
  #   end
  # end
end
