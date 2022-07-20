# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe Requests::RequestableDecorator do
  include ActionView::TestCase::Behavior

  subject(:decorator) { described_class.new(requestable, view) }
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu",
      ldap: ldap }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user: user, session: {}, patron: valid_patron) }

  let(:requestable) { instance_double(Requests::Requestable, stubbed_questions) }
  let(:default_stubbed_questions) { { patron: patron, etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: false, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, clancy?: false, held_at_marquand_library?: false, item_at_clancy?: false, cul_avery?: false, resource_shared?: false, eligible_for_library_services?: true } }
  let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false) }
  let(:ldap) { {} }

  describe "#digitize?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: true) }
    it 'can not be digitized' do
      expect(decorator.digitize?).to be_falsey
    end

    context "no item data and does not circulate and is recap_edd" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true) }
      it 'can be digitized' do
        expect(decorator.digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, ill_eligible?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, borrow_direct?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, traceable?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and in process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, in_process?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd and on order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, on_order?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is recap_edd service but not recap_edd" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: false) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "no item data and does not circulate and is not recap_edd" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ['on_shelf'], recap_edd?: false) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is not recap_edd is not on_shelf edd" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf'], recap_edd?: false) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is not recap_edd but is on_shelf edd and not on_order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false) }
      it 'can be digitized' do
        expect(decorator.digitize?).to be_truthy
      end
    end

    context "with item data and does not circulate but is on_shelf edd and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and but is on_shelf edd and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is but is on_shelf edd and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and in process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: true, borrow_direct?: false, ill_eligible?: false) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_truthy
      end
    end

    context "with item data and does circulate and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and in process " do
      let(:stubbed_questions) { default_stubbed_questions.merge(services: ['on_shelf_edd'], on_order?: false, in_process?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and on order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(services: ['on_shelf_edd'], on_order?: true) }
      it 'can not be digitized' do
        expect(decorator.digitize?).to be_falsey
      end
    end
  end

  describe "#pick_up?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: true, eligible_to_pickup?: false) }
    it 'can not be picked up' do
      expect(decorator.pick_up?).to be_falsey
    end

    context "a user eligible to pick up" do
      context "not in etas and in_library_only" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and scsb_in_library" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, scsb_in_library_use?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and on_order? " do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and in_process? " do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and traceable" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas borrow_direct?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas and ill_eligible?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(circulates?: true, eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, ill_eligible?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas on_shelf" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf']) }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas on_shelf_edd only" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: true, holding_library_in_library_only?: false, ill_eligible?: false, services: ['on_shelf_edd']) }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas, has item data and circulates not on shelf and recap? and holding_library_in_library_only?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and scsb_in_library" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, scsb_in_library_use?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and on_order" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and in_process" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and traceable?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and borrow_direct?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and ill_eligible?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, ill_eligible?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and recap" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: true, holding_library_in_library_only?: false, ill_eligible?: false, services: ['recap']) }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas, has item data and circulates and annex? and in_library_only" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex? and scsb_in_library_use?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, scsb_in_library_use?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex? and on_order" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex? and in_process" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex? and traceable" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex? and borrow_direct?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex? and ill_eligible?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, ill_eligible?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "not in etas, has item data and circulates and annex?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: true, holding_library_in_library_only?: false, ill_eligible?: false, services: ['annex']) }
        it 'can be picked up' do
          expect(decorator.pick_up?).to be_truthy
        end
      end

      context "not in etas, has item data and circulates not on shelf and not recap? and not annex?" do
        let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_shelf?: false, recap?: false, annex?: false) }
        it 'can be not picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end

      context "in etas" do
        let(:stubbed_questions) { default_stubbed_questions.merge(etas?: true, item_data?: false, circulates?: true, eligible_to_pickup?: true) }
        it 'can not be picked up' do
          expect(decorator.pick_up?).to be_falsey
        end
      end
    end
  end

  describe "#located_in_an_open_library?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(open_libraries: ['abc'], library_code: 'abc') }
    it 'is available for digitizing' do
      expect(decorator.located_in_an_open_library?).to be_truthy
    end

    context "located in an unopen library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(open_libraries: ['abc', 'def'], library_code: '123') }
      it 'is not available for digitizing' do
        expect(decorator.located_in_an_open_library?).to be_falsey
      end
    end
  end

  describe "#fill_in_digitize?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: true) }
    it 'can be fill_in_digitize?' do
      expect(decorator.fill_in_digitize?).to be_truthy
    end

    context "no item data and does not circulate and is recap_edd and not scsb_in_library and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, ill_eligible?: false) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, ill_eligible?: true) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and aeon" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: true) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and in process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: true) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and on order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: false, on_order?: true) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is recap_edd and is scsb_in_library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['recap_edd'], recap_edd?: true, scsb_in_library_use?: true) }
      it 'can be not fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "no item data and does not circulate and is not recap_edd" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, services: ['on_shelf'], recap_edd?: false) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "with item data and does not circulate and is not recap_edd is not on_shelf edd" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf'], recap_edd?: false) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is not recap_edd but is on_shelf edd and not on_order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "with item data and does not circulate but is on_shelf edd and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and but is on_shelf edd and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate and is but is on_shelf edd and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: false, traceable?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and in process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: false, in_process?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does not circulate but is on_shelf edd and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: false, services: ['on_shelf_edd'], recap_edd?: false, on_order?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and not on order and not in process and not traceable and not aeon and not borrow_direct and not ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false) }
      it 'can be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_truthy
      end
    end

    context "with item data and does circulate and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: false, traceable?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and in process " do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: false, in_process?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end

    context "with item data and does circulate and on order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: true, circulates?: true, services: ['on_shelf_edd'], on_order?: true) }
      it 'can not be fill_in_digitize?' do
        expect(decorator.fill_in_digitize?).to be_falsey
      end
    end
  end

  describe "#fill_in_pick_up?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, eligible_to_pickup?: true) }
    it 'can be fill_in_pick_up?' do
      expect(decorator.fill_in_pick_up?).to be_truthy
    end

    context "eligible to pick up and item_data and etas" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, ill_eligible?: false, services: ['on_shelf']) }
      it 'can be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_truthy
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, ill_eligible?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and in_process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: false, in_process?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, scsb_in_library_use?: false, on_order?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and scsb_in_library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: false, scsb_in_library_use?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and circulates and in_library_only" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: true, holding_library_in_library_only?: true) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "eligible to pick up and item_data and on_shelf? and does not circulate" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: true, eligible_to_pickup?: true, etas?: false, on_shelf?: true, circulates?: false) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "not eligible to pick up" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: false) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end

    context "does not circulate" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: false, eligible_to_pickup?: false) }
      it 'can not be fill_in_pick_up?' do
        expect(decorator.fill_in_pick_up?).to be_falsey
      end
    end
  end

  describe "#request?" do
    context "not eligible to pick up" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: false) }
      it 'can not be requested' do
        expect(decorator.request?).to be_falsey
      end
    end

    context "eligible to pick up and any service" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf']) }
      it 'can not be requested' do
        expect(decorator.request?).to be_falsey
      end
    end

    context "eligible to pick up and no services" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: []) }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true) }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: false, in_process?: false, traceable?: true) }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and in_process?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: false, in_process?: true) }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end

    context "eligible to pick up and on_order?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(eligible_to_pickup?: true, on_order?: true) }
      it 'can be requested' do
        expect(decorator.request?).to be_truthy
      end
    end
  end

  describe "#will_submit_via_form?" do
    let(:stubbed_questions) { item_flags.merge(user_flags).merge(location).merge(service) }
    let(:item_flags) { default_stubbed_questions.merge(item_data?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
    let(:service) { { services: ["on_shelf", "on_shelf_edd"], on_shelf?: true } }
    let(:an_open_library) { { open_libraries: ['abc'], library_code: 'abc' } }
    let(:a_closed_library) { { open_libraries: ['def'], library_code: 'abc' } }
    context "a pickup eligible user" do
      let(:user_flags) { { user_barcode: '111222333', eligible_to_pickup?: true } }
      context "at an open library" do
        let(:location) { an_open_library }
        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_truthy
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will not be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, traceable?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, in_process?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, on_order?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end
      end
      context "at a closed library" do
        let(:location) { a_closed_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_truthy
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "Item is a microform in Firestone PF location and stored remotely at Recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_pf?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, traceable?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, in_process?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, on_order?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end
      end
    end
    context "a non pickup eligible user" do
      let(:user_flags) { { eligible_for_library_services?: false, eligible_to_pickup?: false } }
      context "at an open library" do
        let(:location) { an_open_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_falsey
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "item data and at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will not be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, traceable?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, in_process?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, on_order?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end
      end
      context "at a closed library" do
        let(:location) { a_closed_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_falsey
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "item data and at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, traceable?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, in_process?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, on_order?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end
      end
    end
    context "an Alma user" do
      let(:user_flags) { { user_barcode: '111222333', eligible_to_pickup?: true } }
      let(:user) { FactoryBot.build(:alma_patron) }
      context "at an open library" do
        let(:location) { an_open_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_falsey
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false, available?: true } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "item data and at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true, available?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will not be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, traceable?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, in_process?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, on_order?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end
      end
      context "at a closed library" do
        let(:location) { a_closed_library }

        it 'a book on the shelf will be submitted' do
          expect(decorator.will_submit_via_form?).to be_falsey
        end

        context "item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false, available?: true } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "an unavailable item at recap" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: false, available?: false } }

          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "item data and at recap and edd eligible" do
          let(:service) { { services: ["recap"], recap?: true, recap_edd?: true, available?: true } }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_truthy
          end
        end

        context "no item data" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, etas?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and traceable" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, traceable?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and in_process" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, in_process?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end

        context "no item data and etas and on_order" do
          let(:item_flags) { default_stubbed_questions.merge(item_data?: false, etas?: true, on_order?: true, circulates?: true, holding_library_in_library_only?: false, on_shelf?: false, recap_edd?: false, scsb_in_library_use?: false, ill_eligible?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ask_me?: false) }
          it 'will be submitted' do
            expect(decorator.will_submit_via_form?).to be_falsey
          end
        end
      end
    end

    context "no item data and does not circulate and etas and scsb_in_library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false, eligible_to_pickup?: true, ask_me?: false, open_libraries: ['abc'], library_code: 'abc') }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, eligible_for_library_services?: false, eligible_to_pickup?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and in_process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, eligible_for_library_services?: false, eligible_to_pickup?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and ill_eligible and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and ill_eligible and on_order and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, eligible_for_library_services?: false, eligible_to_pickup?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc') }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and traceable and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, eligible_for_library_services?: false, eligible_to_pickup?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and in_process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and in_process and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, eligible_for_library_services?: false, eligible_to_pickup?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and etas and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and etas and on_order and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, eligible_for_library_services?: false, eligible_to_pickup?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc') }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and traceable and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, eligible_for_library_services?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and in_process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and in_process and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, eligible_for_library_services?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and on order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and on order and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, eligible_for_library_services?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', aeon?: false, borrow_direct?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, eligible_for_library_services?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and in_process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, eligible_for_library_services?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and on order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and ill_eligible and on order and no user bar code" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, eligible_for_library_services?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "patron can not pick up materials and no item data and does not circulate and not etas and scsb_in_library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: false, scsb_in_library_use?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, user_barcode: '11122233') }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and traceable and no user barcode " do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: false, traceable?: true, eligible_for_library_services?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and in process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and in process and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: false, in_process?: true, eligible_for_library_services?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: false, on_order?: true, eligible_for_library_services?: false, borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: false, user_barcode: '111222', borrow_direct?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true) }
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and traceable and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: false, traceable?: true, eligible_for_library_services?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap }.with_indifferent_access
      end

      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and in_process" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and in_process and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: false, in_process?: true, eligible_for_library_services?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap }.with_indifferent_access
      end
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and on_order" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and ill_eligible and on_order and no user barcode" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: false, ill_eligible?: true, patron: patron, on_order?: true, eligible_for_library_services?: false, ask_me?: false, open_libraries: ['abc'], library_code: 'abc', aeon?: false) }
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap }.with_indifferent_access
      end
      it 'will not be submitted' do
        expect(decorator.will_submit_via_form?).to be_falsey
      end
    end

    context "no item data and does not circulate and not etas and eligible_to_pickup? and scsb_in_library_use?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(item_data?: false, circulates?: false, services: ["on_shelf"], recap_edd?: false, etas?: false, eligible_to_pickup?: true, scsb_in_library_use?: true) }
      it 'will be submitted' do
        expect(decorator.will_submit_via_form?).to be_truthy
      end
    end
  end

  describe "#request_status?" do
    context "any service" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: ['on_shelf']) }
      it 'can not be requested' do
        expect(decorator.request_status?).to be_falsey
      end
    end

    context "no services" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, services: []) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "ill_eligible" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: true) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "borrow_direct" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: true) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "aeon?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: false, traceable?: false, aeon?: true, borrow_direct?: false, ill_eligible?: false, services: ['any']) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_falsey
      end
    end

    context "traceable" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: false, traceable?: true) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "in_process?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: false, in_process?: true) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end

    context "on_order?" do
      let(:stubbed_questions) { default_stubbed_questions.merge(on_order?: true) }
      it 'can be requested' do
        expect(decorator.request_status?).to be_truthy
      end
    end
  end

  describe "#libcal_url" do
    let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, circulates?: true, recap?: true, location: {}) }
    it "returns a firestone url by default" do
      expect(decorator.libcal_url).to eq('https://libcal.princeton.edu/seats?lid=1919')
    end

    context "an item that is onsite" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, circulates?: true, recap?: false, location: { library: { code: 'lewis' } }) }
      it "returns a firestone url by default" do
        expect(decorator.libcal_url).to eq('https://libcal.princeton.edu/seats?lid=3508')
      end
    end

    context "an item that is at marquand" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, circulates?: true, recap?: true, held_at_marquand_library?: true, location: { library: { code: 'marquand' } }) }
      it "returns a firestone url by default" do
        expect(decorator.libcal_url).to eq('https://libcal.princeton.edu/seats?lid=10656')
      end
    end

    context "an item that is off site with a holding location" do
      let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, circulates?: true, recap?: true, location: { holding_library: { code: 'marquand' } }) }
      it "returns a url" do
        expect(decorator.libcal_url).to eq("https://libcal.princeton.edu/seats?lid=10656")
      end
    end
  end

  describe "#help_me_message" do
    let(:stubbed_questions) { default_stubbed_questions.merge(patron: patron, open_libraries: ['abc'], library_code: 'abc', scsb_in_library_use?: false) }
    let(:ldap) { { pustatus: "undergraduate" } }

    it "returns the unauthorized patron message" do
      expect(decorator.help_me_message).to eq("<p>This item is temporarily not accessible. Library staff will work to try to get you access to a copy of the desired material.</p>")
    end

    context "trained patron" do
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "student",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap, campus_authorized: false, campus_authorized_category: "trained" }.with_indifferent_access
      end

      it "returns the trained patron message" do
        expect(decorator.help_me_message).to eq("<p>This item is temporarily not accessible. Library staff will work to try to get you access to a copy of the desired material.</p>")
      end

      context "closed library" do
        let(:stubbed_questions) { default_stubbed_questions.merge(patron: patron, open_libraries: ['def'], library_code: 'abc') }

        it "returns the correct message" do
          expect(decorator.help_me_message).to eq(I18n.t("requests.help_me.brief_msg.full_access_html"))
        end
      end

      context "scsb in library etas item" do
        let(:stubbed_questions) { default_stubbed_questions.merge(patron: patron, open_libraries: ['abc'], library_code: 'abc', scsb_in_library_use?: true, etas?: true) }

        it "returns the correct message" do
          expect(decorator.help_me_message).to eq(I18n.t("requests.help_me.brief_msg.full_access_html"))
        end
      end
    end

    context "patron with full campus access" do
      let(:valid_patron) do
        { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
          "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
          "patron_id" => "99999", "active_email" => "foo@princeton.edu",
          ldap: ldap,
          campus_authorized: true }.with_indifferent_access
      end

      it "returns the correct message" do
        expect(decorator.help_me_message).to eq(I18n.t("requests.help_me.brief_msg.full_access_html"))
      end
    end

    context "closed library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(patron: patron, open_libraries: ['def'], library_code: 'abc') }

      it "returns the correct message" do
        expect(decorator.help_me_message).to eq(I18n.t("requests.help_me.brief_msg.full_access_html"))
      end
    end

    context "scsb in library etas item" do
      let(:stubbed_questions) { default_stubbed_questions.merge(patron: patron, open_libraries: ['abc'], library_code: 'abc', scsb_in_library_use?: true, etas?: true) }

      it "returns the correct message" do
        expect(decorator.help_me_message).to eq(I18n.t("requests.help_me.brief_msg.full_access_html"))
      end
    end
  end

  describe "#aeon_url" do
    let(:ctx) { instance_double(Requests::SolrOpenUrlContext) }
    context "aeon alma managed" do
      let(:stubbed_questions) do
        { services: ['lewis'], charged?: false, aeon?: true,
          alma_managed?: true, ask_me?: false, aeon_request_url: 'aeon_link' }
      end
      it 'a link for reading room' do
        expect(decorator.aeon_url(ctx)).to eq('aeon_link')
      end
    end

    context "aeon NOT alma managed" do
      let(:stubbed_questions) do
        { services: ['lewis'], charged?: false, aeon?: true,
          alma_managed?: false, ask_me?: false, aeon_request_url: 'link',
          aeon_mapped_params: { abc: 123 } }
      end
      it 'a link for reading room' do
        expect(decorator.aeon_url(ctx)).to eq('https://lib-aeon.princeton.edu/aeon/aeon.dll?abc=123')
      end
    end
  end

  describe "#off_site?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: true) }
    it 'is not off site' do
      expect(decorator.off_site?).to be_falsey
    end

    context "at recap" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap?: true) }
      it 'is off site' do
        expect(decorator.off_site?).to be_truthy
      end
    end

    context "at recap - firestone$pf" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap?: true, recap_pf?: true) }
      it 'is off site' do
        expect(decorator.off_site?).to be_truthy
      end
    end

    context "at annex" do
      let(:stubbed_questions) { default_stubbed_questions.merge(annex?: true) }
      it 'is off site' do
        expect(decorator.off_site?).to be_truthy
      end
    end

    context "at clancy" do
      let(:stubbed_questions) { default_stubbed_questions.merge(clancy?: true, item_at_clancy?: true) }
      it 'is off site' do
        expect(decorator.off_site?).to be_truthy
      end
    end

    context "at annex and recap and clancy" do
      let(:stubbed_questions) { default_stubbed_questions.merge(clancy?: true, annex?: true, recap?: true) }
      it 'is off site' do
        expect(decorator.off_site?).to be_truthy
      end
    end
  end

  describe "#off_site_location?" do
    let(:stubbed_questions) { default_stubbed_questions.merge(etas?: false, item_data?: false, circulates?: true, library_code: 'abc') }
    it 'is not off site' do
      expect(decorator.off_site_location).to eq('abc')
    end

    context "at recap" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap?: true, library_code: 'abc', holding_library: 'abc') }
      it 'is off site' do
        expect(decorator.off_site_location).to eq('recap')
      end
    end

    context "at recap from marquand" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap?: true, library_code: 'abc', holding_library: 'marquand') }
      it 'is off site' do
        expect(decorator.off_site_location).to eq('recap_marquand')
      end
    end

    context "at recap - firestone$pf" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap?: true, recap_pf?: true, library_code: 'firestone$pf', holding_library: 'firestone') }
      it 'is off site' do
        expect(decorator.off_site_location).to eq('recap')
      end
    end

    context "avery item at recap from marquand" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap?: true, library_code: 'abc', cul_avery?: true, holding_library: 'recap') }
      it 'is off site' do
        expect(decorator.off_site_location).to eq('recap_marquand')
      end
    end

    context "at annex" do
      let(:stubbed_questions) { default_stubbed_questions.merge(annex?: true, library_code: 'abc') }
      it 'is off site' do
        expect(decorator.off_site_location).to eq('abc')
      end
    end

    context "at annex" do
      let(:stubbed_questions) { default_stubbed_questions.merge(clancy?: true, library_code: 'abc', item_at_clancy?: true) }
      it 'is off site' do
        expect(decorator.off_site_location).to eq('clancy')
      end
    end
  end

  describe "#delivery_location_label" do
    let(:stubbed_questions) { default_stubbed_questions.merge(held_at_marquand_library?: false, cul_music?: false, location: { delivery_locations: [{ gfa_pickup: 'PJ', label: 'abc' }] }) }
    it 'shows the location label' do
      expect(decorator.delivery_location_label).to eq('abc')
    end

    context "at marquand" do
      let(:stubbed_questions) { default_stubbed_questions.merge(held_at_marquand_library?: true, location: { delivery_locations: [{ gfa_pickup: 'PJ', label: 'abc' }] }) }
      it 'shows the marquand name' do
        expect(decorator.delivery_location_label).to eq('Marquand Library at Firestone')
      end
    end

    context "at Firestone Library, Microforms" do
      let(:stubbed_questions) { default_stubbed_questions.merge(hl_art?: false, cul_music?: false, recap?: true, recap_pf?: true, holding_library: 'recap', location: { delivery_locations: [{ gfa_pickup: 'PF', label: 'Firestone Library, Microforms' }] }) }
      it 'shows Firestone Library, Microforms' do
        expect(decorator.delivery_location_label).to eq('Firestone Library, Microforms')
      end
    end
  end

  describe "#delivery_location_code" do
    let(:stubbed_questions) { default_stubbed_questions.merge(recap_pf?: false, held_at_marquand_library?: false, cul_music?: false, hl_art?: false, location: {}) }
    it 'shows the default location code' do
      expect(decorator.delivery_location_code).to eq('PA')
    end

    context "has a delivery location" do
      let(:stubbed_questions) { default_stubbed_questions.merge(recap_pf?: false, held_at_marquand_library?: true, cul_music?: false, hl_art?: false, location: { delivery_locations: [{ gfa_pickup: 'PJ', label: 'abc' }] }) }
      it 'shows the location code' do
        expect(decorator.delivery_location_code).to eq('PJ')
      end
    end

    context "is an avery item" do
      let(:stubbed_questions) { default_stubbed_questions.merge(held_at_marquand_library?: true, cul_avery?: true, hl_art?: false) }
      it 'shows the location code' do
        expect(decorator.delivery_location_code).to eq('PJ')
      end
    end

    context "is a cul music item" do
      let(:stubbed_questions) { default_stubbed_questions.merge(held_at_marquand_library?: false, cul_avery?: false, hl_art?: false, cul_music?: true) }
      it 'shows the location code' do
        expect(decorator.delivery_location_code).to eq('PK')
      end
    end

    context "is a hl art item" do
      let(:stubbed_questions) { default_stubbed_questions.merge(held_at_marquand_library?: false, cul_avery?: false, hl_art?: true, cul_music?: false) }
      it 'shows the location code' do
        expect(decorator.delivery_location_code).to eq('PJ')
      end
    end

    context "is a PF item" do
      let(:stubbed_questions) { default_stubbed_questions.merge(held_at_marquand_library?: false, cul_avery?: false, hl_art?: false, cul_music?: false, location: { delivery_locations: [{ gfa_pickup: 'PF', label: 'Firestone Library, Microforms' }] }) }
      it 'shows the location code' do
        expect(decorator.delivery_location_code).to eq('PF')
      end
    end
  end

  describe "#help_me?" do
    context "any service in an open library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(ask_me?: false, open_libraries: ['abc12'], services: ['on_shelf'], library_code: 'abc12') }
      it 'does not need help' do
        expect(decorator.help_me?).to be_falsey
      end
    end

    context "ask me" do
      let(:stubbed_questions) { default_stubbed_questions.merge(ask_me?: true, open_libraries: ['abc12'], services: ['on_shelf']) }
      it 'does not need help' do
        expect(decorator.help_me?).to be_truthy
      end
    end

    context "no services in an closed library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(ask_me?: false, open_libraries: ['abc12'], services: [], library_code: nil) }
      it 'does need help' do
        expect(decorator.help_me?).to be_truthy
      end
    end

    context "no services in an open library" do
      let(:stubbed_questions) { default_stubbed_questions.merge(ask_me?: false, open_libraries: ['abc12'], services: [], library_code: 'abc12') }
      it 'does not need help' do
        expect(decorator.help_me?).to be_falsey
      end
    end

    context "no services being resource shared" do
      let(:stubbed_questions) { default_stubbed_questions.merge(resource_shared?: true, ask_me?: false, open_libraries: ['abc12'], services: [], library_code: 'abc12') }
      it 'does not need help' do
        expect(decorator.help_me?).to be_falsey
      end
    end
  end

  describe "#status_badge" do
    let(:stubbed_questions) { default_stubbed_questions.merge(charged?: false, status_label: 'Item in place', status: 'Available') }

    it 'shows the status' do
      expect(decorator.status_badge).to eq('<span class="availability--label badge badge-success">Available - Item in place</span>')
    end

    context 'Status label nil' do
      let(:stubbed_questions) { default_stubbed_questions.merge(charged?: false, status_label: nil, status: 'Available') }

      it 'shows the status' do
        expect(decorator.status_badge).to eq('<span class="availability--label badge badge-success">Available</span>')
      end
    end

    context 'Charged item' do
      let(:stubbed_questions) { default_stubbed_questions.merge(charged?: true, status_label: 'Technical - Migration', status: 'Not Available') }
      it 'shows the status' do
        expect(decorator.status_badge).to eq('<span class="availability--label badge badge-danger">Not Available - Technical - Migration</span>')
      end
    end

    context 'Status and label match' do
      let(:stubbed_questions) { default_stubbed_questions.merge(charged?: true, status_label: 'Not Available', status: 'Not Available') }
      it 'shows the status' do
        expect(decorator.status_badge).to eq('<span class="availability--label badge badge-danger">Not Available</span>')
      end
    end

    context 'migration item that is available' do
      let(:stubbed_questions) { default_stubbed_questions.merge(status_label: 'Technical - Migration', status: 'Available') }
      it 'shows the status' do
        expect(decorator.status_badge).to eq('<span class="availability--label badge badge-success">Available - Technical - Migration</span>')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
