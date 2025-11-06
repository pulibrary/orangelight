# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Requests::ItemHiddenFieldsComponent, type: :component, requests: true do
  let(:bib) { SolrDocument.new id: 'abc123' }
  let(:location) do
    { code: 'location_code' }
  end
  let(:patron) { Requests::Patron.new(patron_hash: {}, user: User.new) }

  it 'renders a hidden location fields' do
    holding = Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' })
    item = Requests::Item.new({ 'id' => "aaabbb", 'location' => 'place' }.with_indifferent_access)
    requestable_decorator = Requests::RequestableDecorator.new(
      Requests::Requestable.new(bib:, holding:, item:, location:, patron:),
      Requests::FormController.new.view_context
    )
    rendered = render_inline described_class.new(requestable_decorator)

    expect(rendered.css('input[type="hidden"][name="requestable[][location_code]"][id="requestable_location_aaabbb"][value="place"]')).to be_present
  end

  it 'renders a hidden barcode field' do
    holding = Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' })
    item = Requests::Item.new({ 'id' => "aaabbb", 'barcode' => '111222333' }.with_indifferent_access)
    requestable_decorator = Requests::RequestableDecorator.new(
      Requests::Requestable.new(bib:, holding:, item:, location:, patron:),
      Requests::FormController.new.view_context
    )
    rendered = render_inline described_class.new(requestable_decorator)

    expect(rendered.css('input[type="hidden"][name="requestable[][barcode]"][id="requestable_barcode_aaabbb"][value="111222333"]')).to be_present
  end

  it 'renders a hidden item enumeration field' do
    holding = Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' })
    item = Requests::Item.new({ 'id' => "aaabbb", 'enum_display' => 'vvv' }.with_indifferent_access)
    requestable_decorator = Requests::RequestableDecorator.new(
      Requests::Requestable.new(bib:, holding:, item:, location:, patron:),
      Requests::FormController.new.view_context
    )
    rendered = render_inline described_class.new(requestable_decorator)

    expect(rendered.css('input[type="hidden"][name="requestable[][enum]"][id="requestable_enum_aaabbb"][value="vvv"]')).to be_present
  end

  it 'renders a holding call number' do
    holding = Requests::Holding.new(mfhd_id: "1594697", holding_data: { "location" => "Firestone Library", "library" => "Firestone Library", "location_code" => "f", "copy_number" => "0", "call_number" => "6251.9765", "call_number_browse" => "6251.9765" })
    item = Requests::Item.new({ 'id' => "aaabbb", 'enum_display' => 'vvv' }.with_indifferent_access)
    requestable_decorator = Requests::RequestableDecorator.new(
      Requests::Requestable.new(bib:, holding:, item:, location:, patron:),
      Requests::FormController.new.view_context
    )

    rendered = render_inline described_class.new(requestable_decorator)

    expect(rendered.css('input[type="hidden"][name="requestable[][call_number]"][id="requestable_call_number_aaabbb"][value="6251.9765"]')).to be_present
  end

  it 'renders scsb hidden fields for a NYPL item' do
    holding = Requests::Holding.new(mfhd_id: 'mfhd1', holding_data: { key1: 'value1' })
    item = Requests::Item.new({ 'id' => "aaabbb", 'location_code' => 'scsbnypl', 'use_statement' => 'In Library Use', 'collection_code' => 'NA', 'cgd' => 'Shared' }.with_indifferent_access)
    requestable_decorator = Requests::RequestableDecorator.new(
      Requests::Requestable.new(bib:, holding:, item:, location:, patron:),
      Requests::FormController.new.view_context
    )

    rendered = render_inline described_class.new(requestable_decorator)

    expect(rendered.css('input[type="hidden"][name="requestable[][cgd]"][id="requestable_cgd_aaabbb"][value="Shared"]')).to be_present
    expect(rendered.css('input[type="hidden"][name="requestable[][cc]"][id="requestable_collection_code_aaabbb"][value="NA"]')).to be_present
    expect(rendered.css('input[type="hidden"][name="requestable[][use_statement]"][id="requestable_use_statement_aaabbb"][value="In Library Use"]')).to be_present
  end
end
