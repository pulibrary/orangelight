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
          gfa_pickup: "PT",
          pick_up_location_code: "engineering",
          staff_only: false,
          library: { label: "Engineering Library", code: "engineer" }
        },
        {
          label: "Lewis Library",
          gfa_pickup: "PN",
          pick_up_location_code: "lewis",
          staff_only: false,
          library: { label: "Lewis Library", code: "lewis" }
        }
      ]
    end

    let(:requestable) do
      instance_double(Requests::RequestableDecorator,
                      annex?: false,
                      holding_library: 'lewis',
                      ill_eligible?: false,
                      location: Requests::Location.new({ code: 'firestone$stacks', delivery_locations: sample_locations, fulfillment_unit: 'General' }),
                      preferred_request_id: 'test123',
                      charged?: false,
                      partner_holding?: false,
                      recap?: false)
    end

    before do
      allow(helper).to receive(:show_pick_up_service_options).and_return(nil)
      allow(helper).to receive(:pick_up_locations).and_return(sample_locations)
    end

    it 'uses custom prompt with recommended location and includes all locations as options' do
      result = helper.preferred_request_content_tag(requestable:, form: nil)

      # Should use custom prompt text with recommended location
      expect(result).to include('<option disabled="disabled" value="">Select a Delivery Location (Recommended: Engineering Library)</option>')

      # Should include Engineering Library as a selectable option
      expect(result).to include('PT&quot;,&quot;pick_up_location_code&quot;:&quot;engineering&quot;}">Engineering Library</option>')

      # Should still include other locations as options
      expect(result).to include('>Firestone Library</option>')
      expect(result).to include('>Lewis Library</option>')
    end

    it 'pre-selects the recommended holding library option' do
      result = helper.preferred_request_content_tag(requestable:, form: nil)

      # Should have Engineering Library pre-selected for lewis holding library
      expect(result).to include('selected="selected"')
      expect(result).to include('<option selected="selected" value="{&quot;pick_up&quot;:&quot;PT&quot;,&quot;pick_up_location_code&quot;:&quot;engineering&quot;}">Engineering Library</option>')
    end

    context 'when holding library is firestone' do
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        annex?: false,
                        holding_library: 'firestone',
                        ill_eligible?: false,
                        location: Requests::Location.new({ code: 'firestone$stacks', delivery_locations: [{ label: "Firestone Library", gfa_pickup: "PA", library: { code: 'firestone' }, pick_up_location_code: 'firestone' }, { label: "Architecture Library", gfa_pickup: "PW", library: { code: 'arch' } }], fulfillment_unit: 'General' }),
                        partner_holding?: false,
                        preferred_request_id: 'test456',
                        charged?: false,
                        recap?: false)
      end

      it 'pre-selects Firestone Library option' do
        result = helper.preferred_request_content_tag(requestable:, form: nil)

        # Should have Firestone Library pre-selected for firestone holding library
        expect(result).to include('<option selected="selected" value="{&quot;pick_up&quot;:&quot;PA&quot;,&quot;pick_up_location_code&quot;:&quot;firestone&quot;}">Firestone Library</option>')
      end
    end

    context 'when item is ReCAP' do
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        annex?: false,
                        partner_holding?: true,
                        holding_library: 'recap',
                        ill_eligible?: false,
                        item: { collection_code: 'ABC' },
                        location: Requests::Location.new({ code: 'scsbcul', delivery_locations: sample_locations }),
                        preferred_request_id: 'test789',
                        charged?: false,
                        recap?: true)
      end

      it 'uses default prompt and does not pre-select anything' do
        result = helper.preferred_request_content_tag(requestable:, form: nil)

        # Should use default prompt text (not custom) and have it selected
        expect(result).to include('<option disabled="disabled" selected="selected" value="">Select a Delivery Location</option>')

        # Should have only one selected option (the prompt)
        expect(result.scan('selected="selected"').length).to eq(1)

        # Should still include all valid pickup locations as options (Lewis is not a valid pickup location)
        expect(result).to include('>Firestone Library</option>')
        expect(result).to include('>Engineering Library</option>')
      end
    end

    context 'when custom prompt returns nil' do
      let(:requestable) do
        instance_double(Requests::RequestableDecorator,
                        holding_library: 'unknown',
                        preferred_request_id: 'test123',
                        charged?: false,
                        recap?: false,
                        ill_eligible?: false,
                        partner_holding?: false,
                        location: Requests::Location.new({ code: 'firestone$stacks', delivery_locations: [{ label: "Firestone Library", gfa_pickup: "PA", library: { code: 'firestone' }, pick_up_location_code: 'firestone' }, { label: "Engineering Library", gfa_pickup: "PT", library: { code: 'engineer' } }, { label: "Lewis Library", gfa_pickup: "PN", library: { code: 'lewis' } }], fulfillment_unit: 'General' }),
                        annex?: false)
      end

      it 'includes all locations in select options when no custom prompt' do
        result = helper.preferred_request_content_tag(requestable:, form: nil)

        # Should include all locations as options
        expect(result).to include('>Firestone Library<')
        expect(result).to include('>Engineering Library<')
        expect(result).to include('>Lewis Library<')
      end
    end
  end
end
