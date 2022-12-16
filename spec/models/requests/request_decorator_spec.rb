# frozen_string_literal: true
require 'rails_helper'

describe Requests::RequestDecorator do
  include ActionView::TestCase::Behavior

  subject(:decorator) { described_class.new(request, view) }
  let(:user) { FactoryBot.build(:user) }
  let(:test_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "staff",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu",
      ldap: }.with_indifferent_access
  end
  let(:campus_unauthorized_patron) { File.open('spec/fixtures/bibdata_patron_unauth_response.json') }
  let(:patron) { Requests::Patron.new(user:, session: {}, patron: test_patron) }

  let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }
  let(:request) do
    instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [requestable], patron:, first_filtered_requestable: requestable,
                                       display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en', eligible_for_library_services?: patron.eligible_for_library_services?)
  end
  let(:solr_context) { instance_double(Requests::SolrOpenUrlContext) }
  let(:stubbed_questions) { {} }
  let(:ldap) { {} }

  describe "#bib_id" do
    it 'is the system id' do
      expect(decorator.bib_id).to eq('123abc')
    end
  end

  describe "#catalog_url" do
    it 'points to the catalog' do
      expect(decorator.catalog_url).to eq('/catalog/123abc')
    end
  end

  describe "#patron_message" do
    context "student ldap status" do
      let(:ldap) { { status: 'student', pustatus: "undergraduate" } }
      it 'does not show a message' do
        expect(decorator.patron_message).to be_blank
      end
    end

    context "staff ldap status" do
      let(:ldap) { { status: 'staff' } }
      it 'does not show a message' do
        expect(decorator.patron_message).to eq ""
      end
    end

    context "faculty ldap status" do
      let(:ldap) { { status: 'faculty' } }
      it 'does not show a message' do
        expect(decorator.patron_message).to eq ""
      end
    end

    context 'user not yet logged in' do
      let(:user) { FactoryBot.build(:user, guest: true, uid: nil) }
      let(:patron) { Requests::Patron.new(user:, session: {}, patron: HashWithIndifferentAccess.new) }
      it 'does not show a message' do
        expect(decorator.patron_message).to eq ""
      end
    end
  end

  describe "#hidden_fields" do
    it "shows all display metdata" do
      expect(decorator.hidden_fields).to eq('<input type="hidden" name="bib[id]" id="bib_id" value="123abc" autocomplete="off" /><input type="hidden" name="bib[title]" id="bib_title" value="title" autocomplete="off" /><input type="hidden" name="bib[author]" id="bib_author" value="author" autocomplete="off" /><input type="hidden" name="bib[isbn]" id="bib_isbn" value="isbn" autocomplete="off" />')
    end
  end

  describe "#format_brief_record_display" do
    it "shows all display metadata" do
      expect(decorator.format_brief_record_display).to eq('<dl class="dl-horizontal"><dt>Title</dt><dd lang="en" id="title">t</dd><dt>Author/Artist</dt><dd lang="en" id="authorartist">a</dd></dl>')
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

    context "on_order services" do
      let(:stubbed_questions) { { services: ['on_order'] } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_fill_in_eligible?).to be_falsey
      end
    end
  end

  describe "#any_will_submit_via_form?" do
    context "recap services" do
      let(:stubbed_questions) { { services: ['recap', 'recap_edd'], patron:, will_submit_via_form?: true, item_data?: true, recap_edd?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, eligible_for_library_services?: true } }
      it "identifies any mfhds that require fill in option" do
        expect(decorator.any_will_submit_via_form?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], patron:, item_data?: false, circulates?: true, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, user_barcode: '111222', ask_me?: false, recap?: false, annex?: false, clancy?: false, held_at_marquand_library?: false, item_at_clancy?: false, open_libraries: ['abc'], library_code: 'abc', eligible_for_library_services?: true } }
      it "submits via form" do
        expect(decorator.any_will_submit_via_form?).to be_truthy
      end
    end

    context "on_shelf services with no item data and circulates" do
      let(:stubbed_questions) { { services: ['on_shelf'], patron:, item_data?: false, circulates?: false, recap_edd?: false, scsb_in_library_use?: false, on_order?: false, in_process?: false, traceable?: false, aeon?: false, borrow_direct?: false, ill_eligible?: false, user_barcode: '111222', ask_me?: false, recap?: false, annex?: false, clancy?: false, item_at_clancy?: false, held_at_marquand_library?: false, open_libraries: ['abc'], library_code: 'abc', eligible_for_library_services?: true } }
      it "does not submit via form" do
        expect(decorator.any_will_submit_via_form?).to be_falsey
      end
    end

    context "user is not eligible for library services" do
      let(:request) do
        instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [requestable], patron:, first_filtered_requestable: requestable,
                                           display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en', eligible_for_library_services?: false)
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
      request = instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [request1, request2], patron:, first_filtered_requestable: requestable,
                                                   display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en')
      decorator = described_class.new(request, view)
      expect(decorator.only_aeon?).to be_truthy
    end

    it "Is not aeon when one request is not aeon" do
      request1 = instance_double(Requests::RequestableDecorator, aeon?: true)
      request2 = instance_double(Requests::RequestableDecorator, aeon?: false)
      request = instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [request1, request2], patron:, first_filtered_requestable: requestable,
                                                   display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en')
      decorator = described_class.new(request, view)
      expect(decorator.only_aeon?).to be_falsey
    end
  end

  describe "#location_label?" do
    it "shows the library name" do
      request = instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [], patron:, first_filtered_requestable: requestable,
                                                   display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en', holdings: { '112233' => { "library" => 'abc' } })
      decorator = described_class.new(request, view)
      expect(decorator.location_label).to eq('abc')
    end

    it "shows the library name and location" do
      request = instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [], patron:, first_filtered_requestable: requestable,
                                                   display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en', holdings: { '112233' => { "library" => 'abc', "location" => "123" } })
      decorator = described_class.new(request, view)
      expect(decorator.location_label).to eq('abc - 123')
    end

    it "shows the nothing if the holding is empty" do
      request = instance_double(Requests::Request, system_id: '123abc', mfhd: '112233', ctx: solr_context, requestable: [], patron:, first_filtered_requestable: requestable,
                                                   display_metadata: { title: 'title', author: 'author', isbn: 'isbn' }, language: 'en', holdings: {})
      decorator = described_class.new(request, view)
      expect(decorator.location_label).to eq('')
    end
  end
end
