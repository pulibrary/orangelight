# frozen_string_literal: true
require 'rails_helper'

describe Requests::FormDecorator, requests: true do
  include ActionView::TestCase::Behavior

  subject(:decorator) { described_class.new(request, view, '/catalog/123abc') }
  let(:user) { FactoryBot.build(:user) }
  let(:test_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "REG",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu",
      ldap: }.with_indifferent_access
  end
  let(:campus_unauthorized_patron) { File.open('spec/fixtures/bibdata_patron_unauth_response.json') }
  let(:patron) { Requests::Patron.new(user:, patron_hash: test_patron) }

  let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }
  let(:hidden_field_metadata) do
    { title: 'title', author: 'author', isbn: 'isbn' }
  end
  let(:request) do
    instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [requestable], patron:, first_filtered_requestable: requestable,
                                    hidden_field_metadata:, eligible_for_library_services?: patron.eligible_for_library_services?)
  end
  let(:solr_context) { instance_double(Requests::SolrOpenUrlContext) }
  let(:stubbed_questions) { {} }
  let(:ldap) { {} }

  before do
    allow(request).to receive(:too_many_items?).and_return(false)
  end

  describe "#bib_id" do
    it 'is the system id' do
      expect(decorator.bib_id).to eq('123abc')
    end
  end

  describe "#hidden_fields" do
    let(:hidden_field_metadata) do
      { title: 'title', author: 'author', isbn: 'isbn', date: '1Q84' }
    end
    it "shows all display metdata" do
      expect(decorator.hidden_fields).to eq('<input type="hidden" name="bib[id]" id="bib_id" value="123abc" autocomplete="off" /><input type="hidden" name="bib[title]" id="bib_title" value="title" autocomplete="off" /><input type="hidden" name="bib[author]" id="bib_author" value="author" autocomplete="off" /><input type="hidden" name="bib[isbn]" id="bib_isbn" value="isbn" autocomplete="off" /><input type="hidden" name="bib[date]" id="bib_date" value="1Q84" autocomplete="off" />')
    end
  end

  describe "#fill_in_eligible" do
    context "recap services" do
      let(:stubbed_questions) { { services: ['recap', 'recap_edd'] } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_falsey
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], item_data?: false, circulates?: true } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_truthy
      end
    end

    context "on_shelf services with no item data and does not circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], item_data?: false, circulates?: false } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_falsey
      end
    end

    context "on_shelf services with item data that is not enumerated" do
      let(:stubbed_questions) { { services: ['on_shelf'], item_data?: true, circulates?: false, enumerated?: false } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_falsey
      end
    end

    context "on_shelf services with item data that is enumerated" do
      let(:stubbed_questions) { { services: ['on_shelf'], item_data?: true, circulates?: false, enumerated?: true } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_truthy
      end
    end

    context 'has too many items to get from bibdata without timing out' do
      let(:stubbed_questions) { { services: ['recap_no_items'], item_data?: false, circulates?: false, enumerated?: false } }
      before do
        allow(request).to receive(:too_many_items?).and_return(true)
      end
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_truthy
      end
    end

    context "on_order services" do
      let(:stubbed_questions) { { services: ['on_order'] } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_falsey
      end
    end
  end

  describe "#any_will_submit_via_form?" do
    context "recap services" do
      let(:stubbed_questions) { { services: ['recap', 'recap_edd'], patron:, will_submit_via_form?: true, item_data?: true, recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, aeon?: false, ill_eligible?: false, eligible_for_library_services?: true } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_will_submit_via_form?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], patron:, item_data?: false, circulates?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, aeon?: false, ill_eligible?: false, ask_me?: false, recap?: false, annex?: false, held_at_marquand_library?: false, library_code: 'abc', eligible_for_library_services?: true } }
      it "submits via form" do
        expect(decorator.any_will_submit_via_form?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], patron:, item_data?: false, circulates?: false, recap_edd?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, aeon?: false, ill_eligible?: false, ask_me?: false, recap?: false, annex?: false, held_at_marquand_library?: false, eligible_for_library_services?: true } }
      it "does not submit via form" do
        expect(decorator.any_will_submit_via_form?).to be_falsey
      end
    end

    context "user is not eligible for library services" do
      let(:request) do
        instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [requestable], patron:, first_filtered_requestable: requestable,
                                        hidden_field_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, eligible_for_library_services?: false)
      end
      let(:stubbed_questions) { { eligible_for_library_services?: false } }
      it "does not submit via form" do
        expect(decorator.any_will_submit_via_form?).to be_falsey
      end
    end
  end

  describe "#single_item_request?" do
    context "recap services" do
      let(:stubbed_questions) { { services: ['recap', 'recap_edd'] } }
      it "is a single item" do
        expect(decorator.single_item_request?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], item_data?: false, circulates?: true } }
      it "is not a single item" do
        expect(decorator.single_item_request?).to be_falsey
      end
    end
  end

  describe "#only_aeon?" do
    it "Is aeon when every request is aeon" do
      request1 = instance_double(Requests::RequestableDecorator, aeon?: true)
      request2 = instance_double(Requests::RequestableDecorator, aeon?: true)
      request = instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [request1, request2], patron:, first_filtered_requestable: requestable,
                                                hidden_field_metadata: { title: 'title', author: 'author', isbn: 'isbn' })
      decorator = described_class.new(request, view, '/catalog/123abc')
      expect(decorator.only_aeon?).to be_truthy
    end

    it "Is not aeon when one request is not aeon" do
      request1 = instance_double(Requests::RequestableDecorator, aeon?: true)
      request2 = instance_double(Requests::RequestableDecorator, aeon?: false)
      request = instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [request1, request2], patron:, first_filtered_requestable: requestable,
                                                hidden_field_metadata: { title: 'title', author: 'author', isbn: 'isbn' })
      decorator = described_class.new(request, view, '/catalog/123abc')
      expect(decorator.only_aeon?).to be_falsey
    end
  end

  describe "#location_label?" do
    it "shows the library name" do
      request = instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [], patron:, first_filtered_requestable: requestable,
                                                hidden_field_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, holdings: { '112233' => { "library" => 'abc' } })
      decorator = described_class.new(request, view, '/catalog/123abc')
      expect(decorator.location_label).to eq('abc')
    end

    it "shows the library name and location" do
      request = instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [], patron:, first_filtered_requestable: requestable,
                                                hidden_field_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, holdings: { '112233' => { "library" => 'abc', "location" => "123" } })
      decorator = described_class.new(request, view, '/catalog/123abc')
      expect(decorator.location_label).to eq('abc - 123')
    end

    it "shows the nothing if the holding is empty" do
      request = instance_double(Requests::Form, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [], patron:, first_filtered_requestable: requestable,
                                                hidden_field_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, holdings: {})
      decorator = described_class.new(request, view, '/catalog/123abc')
      expect(decorator.location_label).to eq('')
    end
  end
end
