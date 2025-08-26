# frozen_string_literal: true
require "rails_helper"

RSpec.describe Requests::RequestableFormOptionComponent, :requests, type: :component do
  it 'offers both a digitize and pick up option if both are eligible' do
    with_controller_class Requests::FormController do
      mfhd = '22701449030006421'
      holding = Requests::Holding.new(mfhd_id: mfhd, holding_data: { 'location_code' => 'firestone$stacks' })
      item = Requests::Item.new({ 'barcode' => '32101064185703' })
      bib = SolrDocument.new
      status_badge = '<span class=\"availability--label badge bg-success\">Available</span>'.html_safe
      requestable = double Requests::Requestable
      allow(requestable).to receive_messages(
        digitize?: true, pick_up?: true, will_submit_via_form?: true, aeon?: false, item_at_clancy?: false,
        preferred_request_id: '23701449010006421', bib: bib, holding: holding, item_location_code: 'firestone$stacks',
        item?: true, item:, partner_holding?: false, status_badge:, use_restriction?: false, holding_library: 'firestone',
        services: ['on_shelf_edd', 'on_shelf'], fill_in_pick_up?: true,
        pick_up_locations: [{ "label" => "Firestone Library" }], on_shelf?: true, no_services?: false,
        ill_eligible?: false, pending?: false, location: Requests::Location.new({}), charged?: false,
        off_site_location: 'firestone', enum_value: '', cron_value: '', illiad_request_parameters: {},
        location_label: 'Firestone Library - Stacks', call_number: 'Q125 .S35 2007', patron_should_contact_marquand?: false
      )
      default_pick_ups = [{ label: "Firestone Library", gfa_pickup: "PF", pick_up_location_code: "firestone", staff_only: false }]
      form = double Requests::Form
      allow(form).to receive_messages ctx: OpenURL::ContextObject.new, single_item_request?: true
      patron = double Requests::Patron

      component = described_class.new(requestable:, mfhd:, default_pick_ups:, form:, patron:)
      rendered = render_inline component

      expect(rendered.css('label').map(&:text)).to include 'Physical Item Delivery', 'Electronic Delivery'
    end
  end

  it 'tells the patron to contact Marquand directly for marquand items in a carrel' do
    with_controller_class Requests::FormController do
      mfhd = '22701449030006421'
      holding = Requests::Holding.new(mfhd_id: mfhd, holding_data: { 'location_code' => 'firestone$stacks' })
      item = Requests::Item.new({ 'barcode' => '32101064185703' })
      bib = SolrDocument.new
      status_badge = '<span class=\"availability--label badge bg-success\">Available</span>'.html_safe
      requestable = double Requests::Requestable
      allow(requestable).to receive_messages(
        patron_should_contact_marquand?: true, digitize?: true, pick_up?: true, will_submit_via_form?: true, aeon?: false,
        preferred_request_id: '23701449010006421', bib: bib, holding: holding, item_location_code: 'marquand$stacks',
        item?: true, item:, partner_holding?: false, status_badge:, use_restriction?: false, holding_library: 'marquand',
        services: ['marquand_page_charged_item'], fill_in_pick_up?: true,
        pick_up_locations: [{ "label" => "Marquand Library" }], on_shelf?: true, no_services?: false,
        ill_eligible?: false, pending?: false, location: Requests::Location.new({}), charged?: false,
        off_site_location: 'marquand', enum_value: '', cron_value: '', illiad_request_parameters: {},
        location_label: 'Marquand Library - Stacks', call_number: 'Q125 .S35 2007', title: 'My title'
      )
      default_pick_ups = [{ label: "Firestone Library", gfa_pickup: "PF", pick_up_location_code: "firestone", staff_only: false }]
      form = double Requests::Form
      allow(form).to receive_messages ctx: OpenURL::ContextObject.new, single_item_request?: true
      patron = double Requests::Patron

      component = described_class.new(requestable:, mfhd:, default_pick_ups:, form:, patron:)
      rendered = render_inline component

      expect(rendered.text).to include 'Item in Use, Ask Staff for Access'
      expect(rendered.text).to include 'Email marquand@princeton.edu for access'
    end
  end
end
