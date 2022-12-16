# frozen_string_literal: true
require 'rails_helper'
include Requests::ApplicationHelper

# rubocop:disable RSpec/MultipleExpectations
# rubocop:disable Metrics/BlockLength
describe Requests::RequestMailer, type: :mailer, vcr: { cassette_name: 'mailer', record: :none } do
  let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }

  let(:user_info) do
    stub_request(:get, "#{Requests::Config[:bibdata_base]}/patron/foo?ldap=true").to_return(status: 200, body: valid_patron_response, headers: {})
    user = instance_double(User, guest?: false, uid: 'foo', alma_provider?: false)
    Requests::Patron.new(user:, session: {})
  end

  let(:guest_user_info) do
    user = instance_double(User, guest?: true, uid: 'foo')
    Requests::Patron.new(user:, session: { "email" => "guest@foo.edu", 'user_name' => 'Guest Request' })
  end

  before { stub_delivery_locations }

  context "send preservation email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "2229149680006421",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "firestone$pres",
          "item_id" => "2329149670006421",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9997123553506421",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_preservation) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("pres_email", submission_for_preservation).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.pres.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.pres.email')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.pres.email_conf_msg')
    end
  end

  context "send preservation email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "2229149680006421",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "firestone$pres",
          "item_id" => "2329149670006421",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9997123553506421",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_preservation) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("pres_confirmation", submission_for_preservation).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.pres.email_subject'))
      expect(mail.to).to eq([submission_for_preservation.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.pres.patron_conf_msg')
    end
  end

  context "send page record with no_items email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "9929080",
          "location_code" => "rcppa",
          "item_id" => "10139326",
          "status" => "Not Charged",
          "type" => "paging",
          "pick_up" => "PN"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "10139326",
        "title" => "Abhath fi al-tasawwuf wa al-turuq al-sufiyah: al-zawayah wa al-marja'iyah al-diniyah..",
        "author" => "Jab al-Khayr, Sa'id"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_no_items) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("paging_email", submission_for_no_items).deliver_now
    end

    let(:confirmation) do
      described_class.send("paging_confirmation", submission_for_no_items).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Paging Request for Lewis Library")
      expect(mail.to).to eq(["fstpage@princeton.edu"])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.paging.email_conf_msg')
    end

    it "renders the confirmation" do
      expect(confirmation.subject).to eq("Paging Request for Lewis Library")
      expect(confirmation.to).to eq([submission_for_no_items.email])
      expect(confirmation.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation.body.encoded).to have_content(I18n.t('requests.paging.email_conf_msg'))
    end
  end

  context "send annex email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22109192590006421",
          "call_number" => "Oversize HQ766 .B53f",
          "location_code" => "firestone$stacks",
          "item_id" => "23109192510006421",
          "status" => "Not Charged",
          "type" => "annex",
          "pick_up" => "PQ"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9922868943506421",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_annex) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("annex_email", submission_for_annex).deliver_now
    end

    let(:confirmation_mail) do
      described_class.send("annex_confirmation", submission_for_annex).deliver_now
    end

    it "renders email to library staffs" do
      expect(mail.subject).to eq(I18n.t('requests.annex.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.annex.email')])
      expect(mail.cc).to be_nil
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.annex.email_conf_msg')
    end

    it "renders email confirmation" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.annex.email_subject'))
      expect(confirmation_mail.to).to eq([submission_for_annex.email])
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.annex.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.annex.email_conf_msg')
    end
  end

  context "send anxadoc email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "2246662610006421",
          "call_number" => "Y 4.C 73/7:S.HRG.109-1132",
          "location_code" => "annex$doc",
          "item_id" => "2346662600006421",
          "status" => "Not Charged",
          "type" => "annex",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9965925893506421",
        "title" => "The Coast Guard's fiscal year 2007 budget request.",
        "author" => "United States"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_anxadoc) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("annex_email", submission_for_anxadoc).deliver_now
    end

    let(:confirmation_mail) do
      described_class.send("annex_confirmation", submission_for_anxadoc).deliver_now
    end

    it "renders and email to the librarians" do
      expect(mail.subject).to eq(I18n.t('requests.annex.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.anxadoc.email')])
      expect(mail.cc).to be_nil
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.annex.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.annex.email_conf_msg')
    end

    it "renders a confirmation" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.annex.email_subject'))
      expect(confirmation_mail.to).to eq([submission_for_anxadoc.email])
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.annex.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.annex.email_conf_msg')
    end
  end

  context "send on_order email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22256196730006421",
          "location_code" => "recap$pa",
          "item_id" => "23256196720006421",
          "status" => "On-Order",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "99100815663506421",
        "title" => "Amidakujishiki Goto Seimei shinpojiumu=zadan hen アミダクジ式ゴトウメイセイ【シンポジウム＝座談篇】",
        "author" => "Goto, Seimei"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_on_order) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("on_order_email", submission_for_on_order).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.on_order.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.on_order.email_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.on_order.email_conf_msg')
    end
  end

  context "send on_order email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22256196730006421",
          "location_code" => "recap$pa",
          "item_id" => "23256196720006421",
          "status" => "On-Order",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "99100815663506421",
        "title" => "Amidakujishiki Goto Seimei shinpojiumu=zadan hen アミダクジ式ゴトウメイセイ【シンポジウム＝座談篇】",
        "author" => "Goto, Seimei"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_on_order) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("on_order_confirmation", submission_for_on_order).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.on_order.email_subject'))
      expect(mail.to).to eq([submission_for_on_order.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.on_order.patron_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.on_order.patron_conf_msg')
    end
  end

  context "send in_process email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "2219343870006421",
          "call_number" => "PQ8098.429.E58 C37 2015",
          "location_code" => "firestone$stacks",
          "item_id" => "2319343860006421",
          "barcode" => "32101098590092",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "in_process"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9996460993506421",
        "title" => "Cartas romanas /",
        "author" => "Serrano del Pozo, Ignacio"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_in_process) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("in_process_email", submission_for_in_process).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.in_process.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.in_process.email_conf_msg')
    end
  end

  context "send in_process email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "2219343870006421",
          "call_number" => "PQ8098.429.E58 C37 2015",
          "location_code" => "firestone$stacks",
          "item_id" => "2319343860006421",
          "barcode" => "32101098590092",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "in_process"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9996460993506421",
        "title" => "Cartas romanas /",
        "author" => "Serrano del Pozo, Ignacio"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_in_process) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("in_process_confirmation", submission_for_in_process).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.in_process.email_subject'))
      expect(mail.to).to eq([submission_for_in_process.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.in_process.email_conf_msg')
    end
  end

  context "send trace email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22114648430006421",
          "call_number" => "GT3405 .L44 2017",
          "location_code" => "firestone$stacks",
          "item_id" => "23114648420006421",
          "barcode" => "32101095686430",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "trace"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "99100059353506421",
        "title" => "The 21st century meeting and event technologies : powerful tools for better planning, marketing, and evaluation /",
        "author" => "Lee, Seungwon Boshnakova, Dessislava Goldblatt, Joe Jeff"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_trace) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("trace_email", submission_for_trace).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.trace.email_subject'))
      expect(mail.to).to eq([I18n.t('requests.default.email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.trace.email_conf_msg')
    end
  end

  context "send trace email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22114648430006421",
          "call_number" => "GT3405 .L44 2017",
          "location_code" => "firestone$stacks",
          "item_id" => "7499956",
          "barcode" => "32101095686430",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "trace"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "99100059353506421",
        "title" => "The 21st century meeting and event technologies : powerful tools for better planning, marketing, and evaluation /",
        "author" => "Lee, Seungwon Boshnakova, Dessislava Goldblatt, Joe Jeff"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_trace) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("trace_confirmation", submission_for_trace).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.trace.email_subject'))
      expect(mail.to).to eq([submission_for_trace.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.trace.email_conf_msg')
    end
  end

  context "send recap email request for authenticated user" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22202822560006421",
          "call_number" => "Oversize DT549 .E274q",
          "location_code" => "recap$pa",
          "item_id" => "23202822550006421",
          "barcode" => "32101098722844",
          "enum_display" => "2016",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_7467161" => "print",
          "pick_up" => "PA",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9999443553506421",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_recap) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("recap_email", submission_for_recap).deliver_now
    end

    let(:confirmation_mail) do
      described_class.send("recap_confirmation", submission_for_recap).deliver_now
    end

    it "sens no email for a registered user" do
      expect(mail).to be_nil
    end

    it "renders the confirmation" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.recap.email_subject'))
      expect(confirmation_mail.to).to eq([submission_for_recap.email])
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.recap.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.recap.email_conf_msg')
    end
  end

  context "send recap edd confirmation request for authenticated user" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22202822560006421",
          "call_number" => "Oversize DT549 .E274q",
          "location_code" => "recap$pa",
          "item_id" => "23202822550006421",
          "barcode" => "32101098722844",
          "enu_display" => "2016",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_7467161" => "print",
          "pick_up" => "PA",
          "edd_start_page" => "1",
          "edd_end_page" => "20",
          "edd_volume_number" => "4",
          "edd_issue" => "1",
          "edd_author" => "author",
          "edd_art_title" => "title",
          "edd_note" => "note"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9999443553506421",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_recap) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("recap_edd_confirmation", submission_for_recap).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.recap_edd.email_subject'))
      expect(mail.to).to eq([submission_for_recap.email])
      expect(mail.cc).to be_nil
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.recap_edd.email_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.recap_edd.email_conf_msg')
    end
  end

  context "send recap email request for guest user" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22202822560006421",
          "call_number" => "Oversize DT549 .E274q",
          "location_code" => "recap$pa",
          "item_id" => "23202822550006421",
          "barcode" => "32101098722844",
          "enum_display" => "2016",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "recap",
          "delivery_mode_7467161" => "print",
          "pick_up" => "PA",
          "edd_start_page" => "",
          "edd_end_page" => "",
          "edd_volume_number" => "",
          "edd_issue" => "",
          "edd_author" => "",
          "edd_art_title" => "",
          "edd_note" => ""
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9999443553506421",
        "title" => "L'écrivain, magazine litteraire trimestriel.",
        "author" => "Association des écrivains du Sénégal"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: guest_user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_recap) do
      Requests::Submission.new(params, guest_user_info)
    end

    let(:mail) do
      described_class.send("recap_email", submission_for_recap).deliver_now
    end

    let(:confirmation_mail) do
      described_class.send("recap_confirmation", submission_for_recap).deliver_now
    end

    it "renders the email to the library" do
      expect(mail.subject).to eq("#{I18n.t('requests.recap_guest.email_subject')} - ACCESS")
      expect(mail.cc).to be_nil
      expect(mail.to).to eq([I18n.t('requests.recap.guest_email_destination')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.html_part.body.to_s).not_to have_content I18n.t('requests.recap_guest.email_conf_msg')
      expect(mail.text_part.body.to_s).not_to have_content I18n.t('requests.recap_guest.email_conf_msg')
    end

    it "renders the confirmation email" do
      expect(confirmation_mail.subject).to eq(I18n.t('requests.recap_guest.email_subject'))
      expect(confirmation_mail.cc).to be_nil
      expect(confirmation_mail.to).to eq([submission_for_recap.email])
      expect(confirmation_mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(confirmation_mail.html_part.body.to_s).to have_content I18n.t('requests.recap_guest.email_conf_msg')
      expect(confirmation_mail.text_part.body.to_s).to have_content I18n.t('requests.recap_guest.email_conf_msg')
    end
  end

  context "send plasma email request" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22188891830006421",
          "call_number" => "QC92.U54 A36 2017",
          "location_code" => "plasma$stacks",
          "item_id" => "23188891820006421",
          "barcode" => "32101101395745",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "ppl",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "99102922693506421",
        "title" => "Adopting the International System of units for radiation measurements in the United States : proceedings of a workshop /",
        "author" => "Kosti, Ourania"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_ppl) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("ppl_email", submission_for_ppl).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.ppl.email_subject'))
      expect(mail.to).to eq(["ppllib@princeton.edu"])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.ppl.email_conf_msg')
    end
  end

  context "send plasma email patron confirmation" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22188891830006421",
          "call_number" => "QC92.U54 A36 2017",
          "location_code" => "plasma$stacks",
          "item_id" => "23188891820006421",
          "barcode" => "32101101395745",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "ppl",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "99102922693506421",
        "title" => "Adopting the International System of units for radiation measurements in the United States : proceedings of a workshop /",
        "author" => "Kosti, Ourania"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_plasma) do
      Requests::Submission.new(params, user_info)
    end

    let(:mail) do
      described_class.send("ppl_confirmation", submission_for_plasma).deliver_now
    end

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t('requests.ppl.email_subject'))
      expect(mail.to).to eq([submission_for_plasma.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_content I18n.t('requests.ppl.email_conf_msg')
    end
  end

  context "Item on shelf in firestone" do
    let(:requestable) do
      [
        {
          "selected" => "true",
          "mfhd" => "22251138630006421",
          "call_number" => "PS3566.I428 A6 2015",
          "location_code" => "firestone$stacks",
          "item_id" => "23251138620006421",
          "barcode" => "32101096297443",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "on_shelf",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9992220243506421",
        "title" => "This angel on my chest : stories",
        "author" => "Pietrzyk, Leslie"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_on_shelf) do
      Requests::Submission.new(params, user_info)
    end
    # rubocop:disable RSpec/ExampleLength
    it "sends the email and renders the headers and body" do
      mail = described_class.send("on_shelf_email", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("#{I18n.t('requests.on_shelf.email_subject')} (FIRESTONE$STACKS) PS3566.I428 A6 2015")
      expect(mail.to).to eq([I18n.t('requests.on_shelf.email')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.on_shelf.email_conf_msg')
    end

    it "sends the confirmation email and renders the headers and body" do
      mail = described_class.send("on_shelf_confirmation", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("Firestone Library #{I18n.t('requests.on_shelf.email_subject_patron')}")
      expect(mail.to).to eq([submission_for_on_shelf.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.body.encoded).to have_content I18n.t('requests.on_shelf.email_conf_msg')
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "Item on shelf in East Asian" do
    let(:requestable) do
      [
        { "selected" => "true",
          "mfhd" => "22223742640006421",
          "call_number" => "PL2727.S2 C574 1998",
          "location_code" => "eastasian$cjk",
          "item_id" => "23223742630006421",
          "barcode" => "32101042398345",
          "copy_number" => "1",
          "status" => "Not Charged",
          "type" => "on_shelf",
          "pick_up" => "PL" }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9935732583506421",
        "title" => "Hong lou fang zhen : Da guan yuan zai Gong wang fu 红楼访真　: 大观园在恭王府　",
        "author" => "Zhou, Ruchang"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end

    let(:submission_for_on_shelf) do
      Requests::Submission.new(params, user_info)
    end

    # rubocop:disable RSpec/ExampleLength
    it "sends the email and renders the headers and body" do
      mail = described_class.send("on_shelf_email", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("#{I18n.t('requests.on_shelf.email_subject')} (EASTASIAN$CJK) PL2727.S2 C574 1998")
      expect(mail.to).to eq(["gestcirc@princeton.edu"])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
    end

    it "sends the confirmation email and renders the headers and body" do
      mail = described_class.send("on_shelf_confirmation", submission_for_on_shelf).deliver_now
      expect(mail.subject).to eq("East Asian Library #{I18n.t('requests.on_shelf.email_subject_patron')}")
      expect(mail.to).to eq([submission_for_on_shelf.email])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.html_part.body.to_s).to have_content I18n.t('requests.on_shelf.email_conf_msg')
      expect(mail.text_part.body.to_s).to have_content I18n.t('requests.on_shelf.email_conf_msg')
    end
    # rubocop:enable RSpec/ExampleLength
  end

  context "Invalid Clancy Item" do
    let(:requestable) do
      [
        { "selected" => "true",
          "mfhd" => "9956200533506421",
          "call_number" => "ND553.P6 D24 2008q Oversize",
          "location_code" => "$marquand$stacks",
          "item_id" => "22590116430006421",
          "barcode" => "32101068477817",
          "copy_number" => "1",
          "status" => "Available",
          "type" => "clancy_in_library",
          "pick_up" => "PJ" }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]
    end
    let(:bib) do
      {
        "id" => "9956200533506421",
        "title" => "Picasso / Philippe Dagen.",
        "author" => "Dagen, Philippe"
      }.with_indifferent_access
    end
    let(:params) do
      {
        request: user_info,
        requestable:,
        bib:
      }
    end
    let(:submission_for_clancy_error) do
      Requests::Submission.new(params, user_info)
    end
    let(:services) do
      [
        Requests::Submissions::Clancy.new(submission_for_clancy_error)
      ]
    end

    before do
      services[0].errors << {
        type: 'clancy',
        error: 'Item is In Process on a PYR Job and cannot be Retrieved',
        bibid: '9956200533506421',
        barcode: '32101068477817'
      }
    end

    it "sends the error email and renders the headers and body with id and barcode" do
      mail = described_class.send("service_error_email", services, submission_for_clancy_error).deliver_now
      expect(mail.subject).to eq(I18n.t('requests.error.service_error_subject'))
      expect(mail.to).to eq([I18n.t('requests.error.service_error_email')])
      expect(mail.from).to eq([I18n.t('requests.default.email_from')])
      expect(mail.html_part.body.to_s).to have_content 'Item is In Process on a PYR Job and cannot be Retrieved'
      expect(mail.text_part.body.to_s).to have_content '9956200533506421'
      expect(mail.text_part.body.to_s).to have_content '32101068477817'
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
