# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
describe Requests::Submission, requests: true do
  include ActiveJob::TestHelper

  let(:valid_patron) do
    { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request",
      "barcode" => "22101007797777", "university_id" => "9999999", "patron_group" => "REG",
      "patron_id" => "99999", "active_email" => "foo@princeton.edu" }.with_indifferent_access
  end
  let(:user_info) do
    user = FactoryBot.create(:user, uid: 'foo')
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end

  context 'A valid submission' do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22113812720006421",
          "call_number" => "HA202 .U581",
          "location_code" => "recap$pa",
          "item_id" => "23113812570006421",
          "delivery_mode_23113812570006421" => "print",
          "barcode" => "32101044283008",
          "enum_display" => "2000 (13th ed.)",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => "",
          "pick_up" => "PF"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "994916543506421",
        "title" => "County and city data book.",
        "author" => "United States",
        "date" => "1949"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission) do
      described_class.new(params, user_info)
    end

    describe "contains" do
      it "no errors" do
        expect(submission.valid?).to be_truthy
        expect(submission.errors.full_messages.size).to eq(0)
      end

      it "a system ID" do
        expect(submission.id).to eq(bib[:id])
      end

      it "a user barcode" do
        expect(submission.user_barcode).to be_truthy
      end

      it "a user name" do
        expect(submission.user_name).to be_truthy
      end

      it "a user email address" do
        expect(submission.email).to be_truthy
      end

      it "one or more items requested attached. " do
        expect(submission.items).to be_truthy
        expect(submission.items).to be_an(Array)
        expect(submission.items.size).to be > 0
      end

      it "basic bibliographic information for a requested title" do
        expect(submission.bib['id']).to be_truthy
      end

      it "one service type" do
        expect(submission.service_types).to be_truthy
        expect(submission.service_types).to be_an(Array)
      end

      it 'does identify as a scsb partner item' do
        expect(submission.partner_item?(submission.items.first)).to be false
      end
    end

    describe '#to_h' do
      before { stub_delivery_locations }
      it 'is compatible with sidekiq' do
        expect({ 'args' => submission.to_h }).to be_compatible_with_sidekiq
      end
      it 'contains a bib' do
        expect(submission.to_h['bib']['id']).to eq '994916543506421'
        expect(submission.to_h['bib']['title']).to eq 'County and city data book.'
      end
      it 'contains items' do
        expect(submission.to_h['items'].first['call_number']).to eq 'HA202 .U581'
      end
      it 'contains an email' do
        expect(submission.to_h['email']).to eq 'foo@princeton.edu'
      end
      it 'contains errors' do
        expect(submission.to_h['errors']).to be_empty
      end
      it 'contains a patron' do
        expect(submission.to_h['patron']['first_name']).to eq 'Foo'
        expect(submission.to_h['patron']['last_name']).to eq 'Request'
      end
      it 'contains a pick_up_location' do
        expect(submission.to_h['pick_up_location']['label']).to eq 'Firestone Library'
      end
      it 'contains a user_barcode' do
        expect(submission.to_h['user_barcode']).to eq '22101007797777'
      end
      it 'contains a user_name' do
        expect(submission.to_h['user_name']).to eq 'foo'
      end
    end
  end

  context 'An invalid Submission' do
    let(:bib) do
      {
        "id" => ""
      }
    end

    let(:invalid_params) do
      {
        request: user_info,
        requestable: [{ "selected" => "true" }],
        bib:
      }
    end

    let(:invalid_submission) do
      described_class.new(invalid_params, user_info)
    end

    describe "invalid" do
      it 'includes error messsages' do
        expect(invalid_submission.valid?).to be_falsy
        expect(invalid_submission.errors.full_messages.size).to be > 0
      end
    end
    describe '#to_h' do
      before { stub_delivery_locations }
      it 'is compatible with sidekiq' do
        expect({ 'args' => invalid_submission.to_h }).to be_compatible_with_sidekiq
      end
    end
  end

  context 'Recap' do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22113812720006421",
          "call_number" => "HA202 .U581",
          "location_code" => "recap$pa",
          "item_id" => "23113812570006421",
          "delivery_mode_3059236" => "print",
          "barcode" => "32101044283008",
          "enum_display" => "2000 (13th ed.)",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => "",
          "pick_up" => "PA"
        },
        {
          "selected" => "true",
          "mfhd" => "22113812720006421",
          "call_number" => "HA202 .U581",
          "location_code" => "recap$pa",
          "item_id" => "23113812580006421",
          "delivery_mode_3059237" => "edd",
          "barcode" => "32101044283008",
          "enum_display" => "2000 (13th ed.)",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "edd_start_page" => "1",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => "",
          "pick_up" => ""
        }
      ]
    end

    let(:bib) do
      {
        "id" => "994916543506421",
        "title" => "County and city data book.",
        "author" => "United States",
        "date" => "1949"
      }
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

    describe "Print Delivery" do
      it 'items have gfa pick-up location code' do
        expect(submission.items[0]['pick_up']).to be_truthy
        expect(submission.items[0]['pick_up']).to be_a(String)
        expect(submission.items[0]['pick_up'].size).to eq(2)
      end
    end

    describe "Eletronic Delivery" do
      it 'items have a valid start page' do
        expect(submission.items[1]['edd_start_page']).to be_truthy
      end
    end
  end

  context 'Invalid Submissions' do
    let(:bib) do
      {
        "id" => "994952203506421",
        "title" => "Journal of the Polynesian Society.",
        "author" => "Polynesian Society (N.Z.)",
        "date" => "1892"
      }
    end
    describe 'An empty submission' do
      let(:requestable) { [] }
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end
      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end
      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'contains an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      describe '#to_h' do
        before { stub_delivery_locations }
        it 'is compatible with sidekiq' do
          expect(submission.to_h).to be_compatible_with_sidekiq
        end
        it 'contains errors' do
          expect(submission.to_h['errors']).to eq({ "items" => [{ "empty_set" => { "text" => "Please Select an Item to Request!", "type" => "options" } }] })
        end
      end
    end

    describe 'A submission without a pick-up location' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "23247008490006421",
            "barcode" => "32101044283008",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "annex",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the item ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('23247008490006421')).to be true
      end
    end

    describe 'A submission without a pick-up location and item ID' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "",
            "barcode" => "",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "annex",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('22247009760006421')).to be true
      end
    end

    describe 'A recap submission without a pick-up location and item ID' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "534137",
            "barcode" => "",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('534137')).to be true
      end
    end
    describe 'A recap submission without delivery type' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "121333",
            "barcode" => "",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
    describe 'A recap print submission without a pick-up location' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "121333",
            "barcode" => "",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "delivery_mode_121333" => "print",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
    describe 'A recap edd submission without start page' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "121333",
            "barcode" => "",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "delivery_mode_121333" => "edd",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "",
            "edd_end_page" => "",
            "edd_volume_number" => "",
            "edd_issue" => "",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
    describe 'A recap edd submission without a title' do
      let(:requestable) do
        [
          {
            "selected" => "true",
            "mfhd" => "22247009760006421",
            "call_number" => "HA202 .U581",
            "location_code" => "recap$pa",
            "item_id" => "121333",
            "barcode" => "",
            "enum_display" => "2000 (13th ed.)",
            "copy_number" => "1",
            "delivery_mode_121333" => "edd",
            "status" => "Not Charged",
            "type" => "recap",
            "edd_start_page" => "1",
            "edd_end_page" => "40",
            "edd_volume_number" => "8",
            "edd_issue" => "30",
            "edd_author" => "",
            "edd_art_title" => "",
            "edd_note" => "",
            "pick_up" => ""
          },
          {
            "selected" => "false"
          }
        ]
      end
      let(:params) do
        {
          request: user_info,
          requestable:,
          bib:
        }
      end

      let(:submission) do
        described_class.new(params, user_info)
      end
      before do
        submission.valid?
      end

      it 'is invalid' do
        expect(submission.valid?).to be false
      end

      it 'has an error message' do
        expect(submission.errors.messages).to be_truthy
      end

      it 'has an error message with the mfhd ID as the message key' do
        expect(submission.errors.messages[:items].first.keys.include?('121333')).to be true
      end
    end
  end

  describe 'A recap_no_items submission without a pick-up location' do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "4978217",
          "call_number" => "B52/140.fehb vol.7",
          "location_code" => "rcppl",
          "location" => "ReCAP - East Asian Library use only",
          "user_supplied_enum" => "test",
          "type" => "recap_no_items",
          "pick_up" => ""
        },
        {
          "selected" => "false"
        }
      ]
    end
    let(:params) do
      {
        request: user_info,
        requestable:
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

    before do
      submission.valid?
    end

    it 'is invalid' do
      expect(submission.valid?).to be false
    end

    it 'has an error message' do
      expect(submission.errors.messages).to be_truthy
    end

    it 'has an error message with the mfhd ID as the message key' do
      expect(submission.errors.messages[:items].first.keys.include?('4978217')).to be true
    end
  end

  describe 'Single Submission for a Print with SCSB Managed data' do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "4222673",
          "call_number" => "708.9 B91",
          "location_code" => "scsbcul",
          "item_id" => "6348205",
          "barcode" => "CU13232533",
          "enum_display" => "",
          "copy_number" => "1",
          "status" => "Available",
          "cgd" => "",
          "cc" => "",
          "use_statement" => "",
          "type" => "recap",
          "delivery_mode_6348205" => "Physical Item Delivery",
          "pick_up" => "QV",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
        },
        {
          "selected" => "false"
        }
      ]
    end
    let(:bib) do
      {
        "id" => "491654",
        "title" => "County and city data book.",
        "author" => "United States",
        "date" => "1949"
      }
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission) do
      described_class.new(params, user_info)
    end

    before do
      submission.valid?
    end

    it 'Identifies as a SCSB partner item' do
      expect(submission.partner_item?(submission.items.first)).to be true
    end
  end

  context 'Marquand multiple Items' do
    let(:requestable) do
      [
        { "selected" => "false" },
        {
          "selected" => "true",
          "bibid" => "9971086883506421",
          "mfhd" => "22604435380006421",
          "call_number" => "ND497.H1686 A3 2011",
          "location_code" => "marquand$stacks",
          "item_id" => "23604435360006421",
          "barcode" => "32101091900280",
          "enum" => "vol.2",
          "copy_number" => "1",
          "status" => "Available",
          "holding_library" => "marquand",
          "edd_art_title" => "",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "vol.2",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_note" => "",
          "edd_genre" => "book",
          "edd_location" => "Marquand Library - Remote Storage: Marquand Use Only",
          "edd_isbn" => "9781905375899",
          "edd_date" => "2011",
          "edd_publisher" => "London: Harvey Miller",
          "edd_call_number" => "ND497.H1686 A3 2011",
          "edd_oclc_number" => "785831434",
          "edd_title" => "The life & letters of Gavin Hamilton (1723-1798) : artist & art dealer in eighteenth-century Rome",
          "type" => "digitize",
          "fill_in" => "false",
          "pick_up" => "{\"pick_up\":\"PJ\",\"pick_up_location_code\":\"marquand\"}"
        }.with_indifferent_access,
        { "selected" => "false" },
        {
          "selected" => "true",
          "bibid" => "9971086883506421",
          "mfhd" => "22604435380006421",
          "call_number" => "ND497.H1686 A3 2011",
          "location_code" => "marquand$stacks",
          "item_id" => "23604435370006421",
          "barcode" => "32101090038579",
          "enum" => "vol.1",
          "copy_number" => "1",
          "status" => "Available",
          "holding_library" => "marquand",
          "edd_art_title" => "",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "vol.1",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_note" => "",
          "edd_genre" => "book",
          "edd_location" => "Marquand Library - Remote Storage: Marquand Use Only",
          "edd_isbn" => "9781905375899",
          "edd_date" => "2011",
          "edd_publisher" => "London: Harvey Miller",
          "edd_call_number" => "ND497.H1686 A3 2011",
          "edd_oclc_number" => "785831434",
          "edd_title" => "The life & letters of Gavin Hamilton (1723-1798) : artist & art dealer in eighteenth-century Rome",
          "type" => "digitize",
          "fill_in" => "false",
          "pick_up" => "{\"pick_up\":\"PJ\",\"pick_up_location_code\":\"marquand\"}"
        }.with_indifferent_access
      ]
    end
    let(:bib) { { "id" => "9971086883506421", "title" => "The life & letters of Gavin Hamilton (1723-1798) : artist & art dealer in eighteenth-century Rome", "author" => "", "isbn" => "9781905375899" } }
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

    it 'Request without delivery mode fails' do
      stub_delivery_locations
      expect { selected_items_validator.validate_selected }.to raise_error
    end
  end

  context 'Marquand Item' do
    let(:requestable) do
      [
        { "selected" => "true", "bibid" => "9956364873506421", "mfhd" => "22587331490006421", "call_number" => "N7668.D6 J64 2008",
          "location_code" => "sa", "item_id" => "23587331480006421", "barcode" => "32101072349515", "copy_number" => "1",
          "status" => "Available", "type" => "marquand_in_library", "fill_in" => "false",
          "delivery_mode_23587331480006421" => "in_library", "pick_up" => "PA" }.with_indifferent_access
      ]
    end

    let(:bib) { { "id" => "9956364873506421", "title" => "Dogs : history, myth, art", "author" => "Johns, Catherine", "isbn" => "9780674030930" } }
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

    describe "#process_submission" do
      it 'items contacts alma and does not email marquand' do
        stub_delivery_locations
        alma_stub = stub_alma_hold_success('9956364873506421', '22587331490006421', '23587331480006421', '9999999')
        expect(submission).to be_valid
        expect do
          submission.process_submission
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(alma_stub).to have_been_requested
      end

      it "returns hold errors" do
        alma_stub = stub_alma_hold_failure('9956364873506421', '22587331490006421', '23587331480006421', '9999999')
        expect do
          submission.process_submission
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(alma_stub).to have_been_requested
        expect(submission.service_errors.first[:type]).to eq('marquand_in_library')
      end
    end
  end

  context 'Annex Item' do
    let(:requestable) do
      [
        { "selected" => "true", "bibid" => "99124704963506421", "mfhd" => "22741721830006421", "call_number" => "QK551 .G723 2021",
          "location_code" => "sa", "item_id" => "23741721820006421", "barcode" => "32101104020456", "copy_number" => "1",
          "status" => "Available", "type" => "annex", "fill_in" => "false",
          "delivery_mode_23741721820006421" => "in_library", "pick_up" => "PA" }.with_indifferent_access
      ]
    end
    let(:bib) { { "id" => "99124704963506421", "title" => "The liverworts and hornworts of Colombia and Ecuador", "author" => "Gradstein, S. R.", "isbn" => "9783030494490" } }
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end
    let(:submission) do
      described_class.new(params, user_info)
    end

    describe "#process_submission" do
      it 'sends an email and places an alma hold' do
        stub_delivery_locations
        alma_stub = stub_alma_hold_success('99124704963506421', '22741721830006421', '23741721820006421', '9999999')
        expect(submission).to be_valid
        expect do
          submission.process_submission
        end.to change { ActionMailer::Base.deliveries.count }.by(2)
        expect(submission.service_errors.count).to eq(0)
        expect(alma_stub).to have_been_requested
      end

      it "returns hold errors" do
        alma_stub = stub_alma_hold_failure('99124704963506421', '22741721830006421', '23741721820006421', '9999999')
        expect do
          submission.process_submission
        end.to change { ActionMailer::Base.deliveries.count }.by(0)
        expect(alma_stub).to have_been_requested
        expect(submission.service_errors.count).to eq(1)
      end
    end
  end

  describe 'new_from_hash' do
    before do
      user = FactoryBot.create(:user, uid: 'jj')
      user.save
    end
    it 'creates a submission with a patron' do
      submission = described_class.new_from_hash({ 'patron' => { 'last_name' => 'Jónsdóttir', 'first_name' => 'Jóna', 'netid' => 'jj', 'active_email' => 'jj@princeton.edu' } })

      expect(submission.patron.last_name).to eq 'Jónsdóttir'
      expect(submission.patron.first_name).to eq 'Jóna'
      expect(submission.patron.cas_provider?).to be true
      expect(submission.email).to eq 'jj@princeton.edu'
    end

    it 'creates a submission with a bib' do
      submission = described_class.new_from_hash({ 'bib' => { 'title' => 'My favorite book' }, 'patron' => { 'netid' => 'jj' } })
      expect(submission.bib['title']).to eq 'My favorite book'
    end

    it 'creates a submission with items that allow string or symbol keys' do
      submission = described_class.new_from_hash({ 'items' => [
                                                   {
                                                     "selected" => "true",
                                                     "location_code" => "recap$pa"
                                                   }
                                                 ], 'patron' => { 'netid' => 'jj' } })
      expect(submission.items.first['location_code']).to eq 'recap$pa'
      expect(submission.items.first[:location_code]).to eq 'recap$pa'
    end
  end
end
# rubocop:enable Metrics/BlockLength
