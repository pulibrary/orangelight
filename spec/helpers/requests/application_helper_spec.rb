# frozen_string_literal: true
require 'rails_helper'
require './app/models/requests/form.rb'

RSpec.describe Requests::ApplicationHelper, type: :helper,
                                            vcr: { cassette_name: 'form_models', record: :none },
                                            requests: true do
  let(:user) { FactoryBot.build(:user) }
  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "22101007797777",
      "university_id" => "9999999", "patron_group" => "REG", "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:patron) do
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end
  let(:patron_request) { instance_double(Thread, value: patron) }

  before { stub_delivery_locations }

  describe '#submit_disabled' do
    let(:user) { FactoryBot.build(:user) }
    let(:params) do
      {
        system_id: '9981794023506421',
        mfhd: '22591269990006421',
        patron_request:
      }
    end
    let(:request_with_items_on_reserve) { Requests::Form.new(**params) }
    let(:requestable_list) { request_with_items_on_reserve.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled?(requestable_list) }
    before do
      stub_single_holding_location 'firestone$stacks'
      stub_catalog_raw bib_id: '9981794023506421'
    end

    it 'returns a boolean to disable/enable submit' do
      expect(submit_button_disabled).to be_truthy
    end

    # temporary for #348
    context "Firestone Classics Collection (Clas)" do
      let(:params) do
        {
          system_id: '9992220243506421',
          mfhd: '22558467250006421',
          patron_request:
        }
      end
      before { stub_catalog_raw bib_id: '9992220243506421' }
      it 'returns a boolean to enable submit for logged in user' do
        assign(:user, user)
        expect(submit_button_disabled).to be_falsey
      end

      it 'returns a boolean to disable submit for guest' do
        assign(:user, nil)
        expect(submit_button_disabled).to be_truthy
      end
    end

    describe 'lewis library' do
      let(:params) do
        {
          system_id: '9938488723506421',
          mfhd: '22522147400006421',
          patron_request:
        }
      end
      before { stub_catalog_raw bib_id: '9938488723506421' }
      it 'lewis is a submitable request' do
        assign(:user, user)
        expect(submit_button_disabled).to be false
      end
    end
  end

  describe 'firestone pick_up_choices' do
    let(:params) do
      {
        system_id: '994916543506421',
        mfhd: '22724990930006421',
        patron_request:
      }
    end
    let(:default_pick_ups) do
      [{ label: "Firestone Library", gfa_pickup: "PA", staff_only: false }, { label: "Architecture Library", gfa_pickup: "PW", staff_only: false }, { label: "East Asian Library", gfa_pickup: "PL", staff_only: false }, { label: "Lewis Library", gfa_pickup: "PN", staff_only: false }, { label: "Marquand Library of Art and Archaeology", gfa_pickup: "PJ", staff_only: false }, { label: "Mendel Music Library", gfa_pickup: "PK", staff_only: false }, { label: "Plasma Physics Library", gfa_pickup: "PQ", staff_only: false }, { label: "Stokes Library", gfa_pickup: "PM", staff_only: false }]
    end
    let(:lewis_request_with_multiple_requestable) { Requests::FormDecorator.new(Requests::Form.new(**params), self, '/catalog/12345') }
    let(:requestable_list) { lewis_request_with_multiple_requestable.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled?(requestable_list) }
    it 'lewis is a submitable request' do
      stub_catalog_raw bib_id: '994916543506421', type: 'alma'
      choices = helper.pick_up_choices(lewis_request_with_multiple_requestable.requestable.last, default_pick_ups)
      expect(choices).to eq("<div id=\"fields-print__23724990920006421\" class=\"collapse request--print\"><div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div><div id=\"fields-print__23724990920006421_card\" class=\"card card-body bg-light\"><input type=\"hidden\" name=\"requestable[][pick_up]\" id=\"requestable__pick_up_23724990920006421\" value=\"{&quot;pick_up&quot;:&quot;PN&quot;,&quot;pick_up_location_code&quot;:&quot;lewis&quot;}\" class=\"single-pick-up-hidden\" autocomplete=\"off\" /><label class=\"single-pick-up\" style=\"\" for=\"requestable__pick_up_23724990920006421\">Pick-up location: Lewis Library</label></div></div>")
    end
  end

  describe 'multiple delivery options' do
    let(:params) do
      {
        system_id: '994264203506421',
        mfhd: '22697858020006421',
        patron_request:
      }
    end
    let(:default_pick_ups) do
      [{ label: "Firestone Library, Resource Sharing", gfa_pickup: "QA", staff_only: true, pick_up_location_code: "firestone" }, { label: "Technical Services 693", gfa_pickup: "QT", staff_only: true, pick_up_location_code: "firestone" }, { label: "Technical Services HMT", gfa_pickup: "QC", staff_only: true, pick_up_location_code: "firestone" }]
    end
    let(:lewis_request_with_multiple_requestable) { Requests::FormDecorator.new(Requests::Form.new(**params), self, '/catalog/12345') }
    let(:requestable_list) { lewis_request_with_multiple_requestable.requestable }
    let(:submit_button_disabled) { helper.submit_button_disabled?(requestable_list) }
    let(:availability_response) { File.read("spec/fixtures/scsb_availability_994264203506421.json") }
    before { stub_catalog_raw bib_id: params[:system_id] }
    it 'lewis is a submitable request' do
      stub_request(:post, "#{Requests.config[:scsb_base]}/sharedCollection/bibAvailabilityStatus")
        .with(body: "{\"bibliographicId\":\"994264203506421\",\"institutionId\":\"PUL\"}")
        .and_return(status: 200, body: availability_response)

      # Mock pick_up_locations to return actual location data instead of using VCR cassette
      pickup_locations = [
        { label: "Firestone Library, Resource Sharing", gfa_pickup: "QA", staff_only: true, pick_up_location_code: "firestone" },
        { label: "Technical Services 693", gfa_pickup: "QT", staff_only: true, pick_up_location_code: "firestone" },
        { label: "Technical Services HMT", gfa_pickup: "QC", staff_only: true, pick_up_location_code: "firestone" }
      ]

      sorted_locations = Requests::Location.sort_pick_up_locations(pickup_locations)
      allow(lewis_request_with_multiple_requestable.requestable.last).to receive(:pick_up_locations).and_return(sorted_locations)

      choices = helper.pick_up_choices(lewis_request_with_multiple_requestable.requestable.last, default_pick_ups)
      expected_choices = "<div id=\"fields-print__22697858020006421\" class=\"collapse request--print show\"><ul class=\"service-list\"><li class=\"service-item\">ReCAP Paging Request, will be delivered to:</li></ul><div id=\"fields-print__22697858020006421_card\" class=\"card card-body bg-light\"><select name=\"requestable[][pick_up]\" id=\"requestable__pick_up_22697858020006421\"><option disabled=\"disabled\" selected=\"selected\" value=\"\">Select a Delivery Location</option>\n<option value=\"{&quot;pick_up&quot;:&quot;QA&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Firestone Library, Resource Sharing (Staff Only)</option>\n<option value=\"{&quot;pick_up&quot;:&quot;QT&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Technical Services 693 (Staff Only)</option>\n<option value=\"{&quot;pick_up&quot;:&quot;QC&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}\">Technical Services HMT (Staff Only)</option></select></div></div>"
      expect(choices).to eq(expected_choices)
    end
  end

  describe '#suppress_login?' do
    let(:unauthenticated_patron) { FactoryBot.build(:unauthenticated_patron) }
    let(:patron) { Requests::Patron.new(user: unauthenticated_patron) }
    let(:params) do
      {
        system_id: '9973529363506421',
        mfhd: '22667098870006421',
        patron_request:
      }
    end
    let(:aeon_only_request) { Requests::FormDecorator.new(Requests::Form.new(**params), nil, '/catalog/12345') }
    let(:login_suppressed) { helper.suppress_login?(aeon_only_request) }
    before { stub_catalog_raw bib_id: params[:system_id] }

    it 'returns a boolean to disable/enable submit' do
      expect(login_suppressed).to be true
    end
  end

  describe '#hidden_fields_mfhd' do
    let(:mfhd) do
      {
        "location" => "ReCAP - Use in Firestone Microforms only",
        "library" => "ReCAP",
        "location_code" => "rcppf",
        "copy_number" => "1",
        "call_number" => "MICROFILM S00534",
        "call_number_browse" => "MICROFILM S00534",
        "location_has" => [
          "No. 22 (Mar. 10/17 1969)-no. 47 (Oct. 6, 1969)",
          "No. 22-47 on reel with no. 1-21 of the earlier title."
        ]
      }
    end

    it 'generates the <input type="hidden"> element markup using MFHD values' do
      expect(helper.hidden_fields_mfhd(mfhd)).to eq \
        "<input type=\"hidden\" name=\"mfhd[][call_number]\" id=\"mfhd__call_number\" value=\"MICROFILM S00534\" autocomplete=\"off\" /><input type=\"hidden\" name=\"mfhd[][location]\" id=\"mfhd__location\" value=\"ReCAP - Use in Firestone Microforms only\" autocomplete=\"off\" /><input type=\"hidden\" name=\"mfhd[][library]\" id=\"mfhd__library\" value=\"ReCAP\" autocomplete=\"off\" />"
    end

    context 'when the MFHD is nil' do
      it 'generates no markup' do
        expect(helper.hidden_fields_mfhd(nil)).to be_empty
      end
    end
  end

  describe "#show_service_options" do
    let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }
    let(:request) { instance_double(Requests::Form, ctx: solr_context) }
    let(:solr_context) { instance_double(Requests::SolrOpenUrlContext) }
    context "lewis library" do
      let(:stubbed_questions) do
        { services: ['on_shelf'], charged?: false, aeon?: false,
          on_shelf?: true, ill_eligible?: false,
          location: { library: { label: "Lewis Library" } } }
      end
      it 'a message for lewis' do
        expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq \
          "<div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div>"
      end
    end

    context "lewis library charged" do
      let(:stubbed_questions) { { charged?: true, aeon?: false, on_shelf?: false } }
      it 'a message for lewis charged' do
        expect(helper).to receive(:render).with(partial: 'checked_out_options', locals: { requestable: }).and_return('partial rendered')
        expect(helper.show_service_options(requestable, 'acb')).to eq "partial rendered"
      end
    end

    context "on shelf" do
      let(:stubbed_questions) do
        { services: ['on_shelf'], charged?: false, aeon?: false,
          alma_managed?: false, on_shelf?: true, ill_eligible?: false,
          location: { library: { label: 'abc' } } }
      end
      it 'a link to a map' do
        assign(:request, request)
        # temporary change no maps everything is pageable
        # expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq "<div><a href=\"map_abc\">Where to find it</a></div>"
        expect(helper.show_pick_up_service_options(requestable, 'acb')).to eq "<div><ul class=\"service-list\"><li class=\"service-item\">Requests for pick-up typically take 2 business days to process.</li></ul></div>"
      end
    end
  end

  describe "#enum_copy_display" do
    let(:requestable) { instance_double(Requests::RequestableDecorator, stubbed_questions) }

    context "with item enumeration" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: Requests::Item.new({ id: "aaabbb", description: 'v.2 sss', copy_number: '0', enum_display: 'v.2' }.with_indifferent_access), holding: Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' }), location: { code: 'location_code' }, partner_holding?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'hides the enum display if the copy number is zero (0)' do
        expect(helper.enum_copy_display(requestable.item)).to eq("v.2 sss")
      end
    end

    context "with item description" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: Requests::Item.new({ id: "aaabbb", description: 'v2 sss', copy_number: '0' }.with_indifferent_access), holding: Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' }), location: { code: 'location_code' }, partner_holding?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'hides the enum display if the copy number is zero (0)' do
        expect(helper.enum_copy_display(requestable.item)).to eq("v2 sss")
      end
    end

    context "with item description and copy" do
      let(:stubbed_questions) { { bib: { id: 'abc123' }, item: Requests::Item.new({ id: "aaabbb", description: 'v2 sss', copy_number: '2' }.with_indifferent_access), holding: Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' }), location: { code: 'location_code' }, partner_holding?: false, preferred_request_id: 'aaabbb', item?: true, item_location_code: '' } }
      it 'hides the enum display if the copy number is zero (0)' do
        expect(helper.enum_copy_display(requestable.item)).to eq("v2 sss Copy 2")
      end
    end
  end

  describe '#pick_up_locations' do
    let(:default_pick_ups) do
      [
        {
          label: "Firestone Library",
          address: "One Washington Rd. Princeton, NJ 08544",
          phone_number: "609-258-1470",
          contact_email: "fstcirc@princeton.edu",
          gfa_pickup: "PA",
          staff_only: false,
          pickup_location: true,
          digital_location: true,
          library: { label: "Firestone Library", code: "firestone", order: 0 },
          pick_up_location_code: "firestone"
        },
        {
          label: "Architecture Library",
          gfa_pickup: "PW",
          staff_only: false,
          pickup_location: true,
          library: { label: "Architecture Library", code: "arch", order: 1 },
          pick_up_location_code: "arch"
        },
        {
          label: "Lewis Library",
          gfa_pickup: "PL",
          staff_only: false,
          pickup_location: true,
          library: { label: "Lewis Library", code: "lewis", order: 2 },
          pick_up_location_code: "lewis"
        }
      ]
    end

    context 'when requestable is ill_eligible' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, ill_eligible?: true) }

      it 'returns first default pickup location' do
        result = helper.send(:pick_up_locations, requestable, default_pick_ups)
        expected = [default_pick_ups[0]]
        expect(result).to eq(expected)
      end
    end

    context 'when requestable is recap' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, ill_eligible?: false, recap?: true, annex?: false) }

      it 'calls recap_annex_available_pick_ups method and returns valid recap/annex locations' do
        expect(described_class).to receive(:recap_annex_available_pick_ups)
          .with(requestable, default_pick_ups)
          .and_call_original

        allow(requestable).to receive(:pick_up_locations).and_return(nil)

        result = helper.send(:pick_up_locations, requestable, default_pick_ups)

        # All default locations have valid gfa_pickup codes (PA, PW, PN are all in the allowed list)
        expect(result).to eq(default_pick_ups)
      end
    end

    context 'when requestable is annex' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, ill_eligible?: false, recap?: false, annex?: true) }

      it 'calls recap_annex_available_pick_ups method and returns valid recap/annex locations' do
        expect(described_class).to receive(:recap_annex_available_pick_ups)
          .with(requestable, default_pick_ups)
          .and_call_original

        allow(requestable).to receive(:pick_up_locations).and_return(nil)

        result = helper.send(:pick_up_locations, requestable, default_pick_ups)

        # All default locations have valid gfa_pickup codes
        expect(result).to eq(default_pick_ups)
      end
    end

    context 'when requestable location has standard_circ_location' do
      let(:location) { instance_double(Requests::Location, standard_circ_location?: true) }
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        ill_eligible?: false,
                        recap?: false,
                        annex?: false,
                        location: location)
      end

      it 'returns default pick ups' do
        result = helper.send(:pick_up_locations, requestable, default_pick_ups)
        expect(result).to eq(default_pick_ups)
      end
    end

    context 'when location exists but standard_circ_location is false' do
      let(:location) do
        instance_double(Requests::Location,
                        standard_circ_location?: false,
                        library_label: 'Special Library',
                        library_code: 'special')
      end
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        ill_eligible?: false,
                        recap?: false,
                        annex?: false,
                        location: location,
                        delivery_location_label: 'Custom Location',
                        delivery_location_code: 'CL',
                        pick_up_location_code: 'custom')
      end

      it 'returns custom delivery location when delivery_location_label is present' do
        result = helper.send(:pick_up_locations, requestable, default_pick_ups)
        expected = [{
          label: 'Custom Location',
          gfa_pickup: 'CL',
          pick_up_location_code: 'custom',
          staff_only: false
        }]
        expect(result).to eq(expected)
      end
    end

    context 'when requestable has delivery_location_label present' do
      let(:location) { instance_double(Requests::Location, standard_circ_location?: false) }
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        ill_eligible?: false,
                        recap?: false,
                        annex?: false,
                        location: location,
                        delivery_location_label: 'Special Collection Library',
                        delivery_location_code: 'SC',
                        pick_up_location_code: 'special')
      end

      it 'returns custom delivery location' do
        result = helper.send(:pick_up_locations, requestable, default_pick_ups)
        expected = [{
          label: 'Special Collection Library',
          gfa_pickup: 'SC',
          pick_up_location_code: 'special',
          staff_only: false
        }]
        expect(result).to eq(expected)
      end
    end

    context 'when delivery_location_label is not present' do
      let(:location) do
        instance_double(Requests::Location,
                        standard_circ_location?: false,
                        library_label: 'East Asian Library',
                        library_code: 'eastasian')
      end
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        ill_eligible?: false,
                        recap?: false,
                        annex?: false,
                        location: location,
                        delivery_location_label: nil)
      end

      before do
        allow(helper).to receive(:gfa_lookup).with('eastasian').and_return('PL')
      end

      it 'returns library-specific location based on library code' do
        result = helper.send(:pick_up_locations, requestable, default_pick_ups)
        expected = [{
          label: 'East Asian Library',
          gfa_pickup: 'PL',
          staff_only: false
        }]
        expect(result).to eq(expected)
      end
    end
  end

  describe '.recap_annex_available_pick_ups' do
    let(:valid_default_pick_ups) do
      [
        {
          label: "Firestone Library",
          gfa_pickup: "PA",
          pick_up_location_code: "firestone",
          staff_only: false
        },
        {
          label: "Architecture Library",
          gfa_pickup: "PW",
          pick_up_location_code: "arch",
          staff_only: false
        }
      ]
    end

    let(:invalid_default_pick_ups) do
      [
        {
          label: "Invalid Location 1",
          gfa_pickup: "XX", # Invalid - not in allowed list
          pick_up_location_code: "invalid1",
          staff_only: false
        },
        {
          label: "Invalid Location 2",
          gfa_pickup: "YY", # Invalid - not in allowed list
          pick_up_location_code: "invalid2",
          staff_only: false
        }
      ]
    end

    context 'when requestable has pick_up_locations with mixed gfa_pickup codes' do
      let(:custom_locations) do
        [
          { label: "Valid Custom Location", gfa_pickup: "PJ", pick_up_location_code: "custom1", staff_only: false },
          { label: "Invalid Custom Location", gfa_pickup: "ZZ", pick_up_location_code: "custom2", staff_only: false }
        ]
      end
      let(:requestable) { instance_double(Requests::RequestableDecorator, pick_up_locations: custom_locations) }

      it 'returns only valid locations based on gfa_pickup codes' do
        result = described_class.recap_annex_available_pick_ups(requestable, valid_default_pick_ups)
        # Only the first custom location should be returned (PJ is valid, ZZ is not)
        expect(result).to eq([custom_locations[0]])
      end
    end

    context 'when requestable has no valid pick_up_locations' do
      let(:custom_locations) do
        [
          { label: "Invalid Location", gfa_pickup: "XX", pick_up_location_code: "invalid", staff_only: false }
        ]
      end
      let(:requestable) { instance_double(Requests::RequestableDecorator, pick_up_locations: custom_locations) }

      it 'returns first default pickup when no valid locations found' do
        result = described_class.recap_annex_available_pick_ups(requestable, valid_default_pick_ups)
        expect(result).to eq([valid_default_pick_ups[0]])
      end
    end

    context 'when requestable has no pick_up_locations' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, pick_up_locations: nil) }

      context 'and default locations have valid gfa_pickup codes' do
        it 'returns all valid default locations' do
          result = described_class.recap_annex_available_pick_ups(requestable, valid_default_pick_ups)
          expect(result).to eq(valid_default_pick_ups)
        end
      end
    end
  end

  describe '#custom_pickup_prompt' do
    let(:sample_locations) do
      [
        {
          label: "Architecture Library",
          library: { label: "Architecture Library", code: "arch" },
          pick_up_location_code: "arch"
        },
        {
          label: "Engineering Library",
          library: { label: "Engineering Library", code: "engineer" },
          pick_up_location_code: "engineer"
        },
        {
          label: "Firestone Library",
          library: { label: "Firestone Library", code: "firestone" },
          pick_up_location_code: "firestone"
        },
        {
          label: "Mendel Music Library",
          library: { label: "Mendel Music Library", code: "mendel" },
          pick_up_location_code: "mendel"
        }
      ]
    end

    context 'when holding_library is lewis' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'lewis', recap?: false) }

      it 'returns Engineering Library' do
        result = helper.send(:custom_pickup_prompt, requestable, sample_locations)
        expect(result).to eq(I18n.t('requests.pick_up_suggested.holding_library', holding_library: 'Engineering Library'))
      end
    end

    context 'when holding_library is plasma' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'plasma', recap?: false) }

      it 'returns Engineering Library' do
        result = helper.send(:custom_pickup_prompt, requestable, sample_locations)
        expect(result).to eq(I18n.t('requests.pick_up_suggested.holding_library', holding_library: 'Engineering Library'))
      end
    end

    context 'when holding_library is engineer' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'engineer', recap?: false) }

      it 'returns Engineering Library' do
        result = helper.send(:custom_pickup_prompt, requestable, sample_locations)
        expect(result).to eq(I18n.t('requests.pick_up_suggested.holding_library', holding_library: 'Engineering Library'))
      end
    end

    context 'when holding_library matches a library code' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'arch', recap?: false) }

      it 'returns the matching library label' do
        result = helper.send(:custom_pickup_prompt, requestable, sample_locations)
        expect(result).to eq(I18n.t('requests.pick_up_suggested.holding_library', holding_library: 'Architecture Library'))
      end
    end

    context 'when holding_library is firestone' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'firestone', recap?: false) }

      it 'returns Firestone Library' do
        result = helper.send(:custom_pickup_prompt, requestable, sample_locations)
        expect(result).to eq(I18n.t('requests.pick_up_suggested.holding_library', holding_library: 'Firestone Library'))
      end
    end

    context 'when holding_library does not match any location' do
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'nonexistent', recap?: false) }

      it 'returns nil' do
        result = helper.send(:custom_pickup_prompt, requestable, sample_locations)
        expect(result).to be_nil
      end
    end

    context 'when Engineering Library is not in locations but special case applies' do
      let(:locations_without_engineering) do
        sample_locations.reject { |loc| loc[:label] == "Engineering Library" }
      end
      let(:requestable) { instance_double(Requests::RequestableDecorator, holding_library: 'lewis', recap?: false) }

      it 'returns nil when Engineering Library is not available' do
        result = helper.send(:custom_pickup_prompt, requestable, locations_without_engineering)
        expect(result).to be_nil
      end
    end
  end

  describe "#preferred_request_content_tag with custom pickup prompt" do
    let(:sample_locations) do
      [
        {
          label: "Firestone Library",
          gfa_pickup: "PA",
          pick_up_location_code: "firestone",
          staff_only: false,
          library: { label: "Firestone Library", code: "firestone" }
        },
        {
          label: "Engineering Library",
          gfa_pickup: "EN",
          pick_up_location_code: "engineering",
          staff_only: false,
          library: { label: "Engineering Library", code: "engineer" }
        },
        {
          label: "Lewis Library",
          gfa_pickup: "SCI",
          pick_up_location_code: "lewis",
          staff_only: false,
          library: { label: "Lewis Library", code: "lewis" }
        }
      ]
    end

    let(:requestable) do
      instance_double(Requests::RequestableDecorator,
                      holding_library: 'lewis',
                      preferred_request_id: 'test123',
                      charged?: false,
                      recap?: false)
    end

    before do
      allow(helper).to receive(:show_pick_up_service_options).and_return(nil)
      allow(helper).to receive(:pick_up_locations).and_return(sample_locations)
    end

    it 'uses custom prompt with recommended location and includes all locations as options' do
      result = helper.preferred_request_content_tag(requestable, sample_locations)

      # Should use custom prompt text with recommended location
      expect(result).to include('<option disabled="disabled" value="">Select a Delivery Location (Recommended: Engineering Library)</option>')

      # Should include Engineering Library as a selectable option
      expect(result).to include('EN&quot;,&quot;pick_up_location_code&quot;:&quot;engineering&quot;}">Engineering Library</option>')

      # Should still include other locations as options
      expect(result).to include('>Firestone Library</option>')
      expect(result).to include('>Lewis Library</option>')
    end

    it 'pre-selects the recommended holding library option' do
      result = helper.preferred_request_content_tag(requestable, sample_locations)

      # Should have Engineering Library pre-selected for lewis holding library
      expect(result).to include('selected="selected"')
      expect(result).to include('<option selected="selected" value="{&quot;pick_up&quot;:&quot;EN&quot;,&quot;pick_up_location_code&quot;:&quot;engineering&quot;}">Engineering Library</option>')
    end

    context 'when holding library is firestone' do
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        holding_library: 'firestone',
                        preferred_request_id: 'test456',
                        charged?: false,
                        recap?: false)
      end

      it 'pre-selects Firestone Library option' do
        result = helper.preferred_request_content_tag(requestable, sample_locations)

        # Should have Firestone Library pre-selected for firestone holding library
        expect(result).to include('<option selected="selected" value="{&quot;pick_up&quot;:&quot;PA&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}">Firestone Library</option>')
      end
    end

    context 'when item is ReCAP' do
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        holding_library: 'firestone',
                        preferred_request_id: 'test789',
                        charged?: false,
                        recap?: true)
      end

      it 'uses default prompt and does not pre-select anything' do
        result = helper.preferred_request_content_tag(requestable, sample_locations)

        # Should use default prompt text (not custom) and have it selected
        expect(result).to include('<option disabled="disabled" selected="selected" value="">Select a Delivery Location</option>')

        # Should have only one selected option (the prompt)
        expect(result.scan('selected="selected"').length).to eq(1)

        # Should still include all locations as options
        expect(result).to include('>Firestone Library</option>')
        expect(result).to include('>Engineering Library</option>')
        expect(result).to include('>Lewis Library</option>')
      end
    end

    context 'when custom prompt returns nil' do
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        holding_library: 'unknown',
                        preferred_request_id: 'test123',
                        charged?: false,
                        recap?: false)
      end

      it 'includes all locations in select options when no custom prompt' do
        result = helper.preferred_request_content_tag(requestable, sample_locations)

        # Should include all locations as options
        expect(result).to include('>Firestone Library<')
        expect(result).to include('>Engineering Library<')
        expect(result).to include('>Lewis Library<')
      end
    end
  end
end
