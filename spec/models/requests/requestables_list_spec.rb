# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::RequestablesList, :requests do
  it 'returns an empty list when the document has no holdings_1display' do
    holdings = { '123' => { library: 'Stokes Library' } }
    list = described_class.new(
      document: SolrDocument.new,
      holdings:,
      mfhd: '123',
      location: nil,
      patron: FactoryBot.build(:patron)
    )
    expect(list.to_a).to be_empty
  end
  it 'returns an empty list when the holding is empty' do
    stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/99999/holdings/123/availability.json").to_return(body: '[]')
    holdings = { '123' => {} }
    list = described_class.new(
      document: SolrDocument.new(id: '99999', holdings_1display: holdings.to_json),
      holdings:,
      location: nil,
      mfhd: '123',
      patron: FactoryBot.build(:patron)
    )
    expect(list.to_a).to be_empty
  end
  it 'returns a list with a single requestable with the holding has no items' do
    stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/99999/holdings/123/availability.json").to_return(body: '[]')
    holdings = { '123' => { library: 'Stokes Library' } }
    list = described_class.new(
      document: SolrDocument.new(id: '99999', holdings_1display: holdings.to_json),
      holdings:,
      location: nil,
      mfhd: '123',
      patron: FactoryBot.build(:patron)
    )
    expect(list.to_a.length).to eq 1
    expect(list.to_a.first.item).to be_a Requests::NullItem
  end
  it 'returns a list with a single requestable with the holding has thousands of items' do
    items = (0..5000).map { { barcode: it.to_s } }
    holdings = { '123' => { library: 'Stokes Library', items: } }
    list = described_class.new(
      document: SolrDocument.new(id: '99999', holdings_1display: holdings.to_json),
      holdings:,
      location: nil,
      mfhd: '123',
      patron: FactoryBot.build(:patron)
    )
    expect(list.to_a.length).to eq 1
    expect(list.to_a.first.item).to be_a Requests::TooManyItemsPlaceholderItem
  end

  it 'creates requestables for Alma items' do
    stub_single_holding_location 'stokes$nb'
    stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/99999/holdings/123/availability.json")
      .to_return(body: '[{"barcode":"my-barcode","status":"Available","status_label":"Item in place","location":"stokes$nb"}]')
    items = [{ barcode: 'my-barcode', holding_id: '123', location: 'stokes$nb' }]
    holdings = { '123' => { library: 'Stokes Library', items: } }

    list = described_class.new(
      document: SolrDocument.new(id: '99999', holdings_1display: holdings.to_json),
      holdings:,
      location: nil,
      mfhd: '123',
      patron: FactoryBot.build(:patron)
    )

    expect(list.to_a.length).to eq 1
    expect(list.to_a.first.barcode).to eq 'my-barcode'
    expect(list.to_a.first).to be_available
  end

  it 'creates a requestable with the permanent location for Alma items in the temporary RES_SHARE$IN_RS_REQ location' do
    stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/99999/holdings/123/availability.json")
      .to_return(body: '[{"barcode":"my-barcode","status":"Unavailable","status_label":"Resource Sharing Request","location":"RES_SHARE$IN_RS_REQ","in_temp_library":true,"temp_library_code":"RES_SHARE","temp_location_code":"RES_SHARE$IN_RS_REQ"}]')
    items = [{ barcode: 'my-barcode', holding_id: '123' }]
    holdings = { '123' => { library: 'Firestone Library', items: } }

    list = described_class.new(
      document: SolrDocument.new(id: '99999', holdings_1display: holdings.to_json),
      holdings:,
      location: { code: 'firestone$stacks', label: 'Firestone Stacks' },
      mfhd: '123',
      patron: FactoryBot.build(:patron)
    )

    expect(list.to_a.length).to eq 1
    expect(list.to_a.first.barcode).to eq 'my-barcode'
    expect(list.to_a.first.location[:code]).to eq 'firestone$stacks'
  end

  it 'creates requestables for SCSB items' do
    stub_single_holding_location 'scsbcul'
    stub_scsb_availability(bib_id: "312044", institution_id: "CUL", barcode: 'CU60224533')
    items = [{ barcode: 'CU60224533', status_at_load: 'Available' }]
    holdings = { '123' => { library: 'ReCAP', location_code: 'scsbcul', location: 'Remote Storage', items: } }.with_indifferent_access

    list = described_class.new(
      document: SolrDocument.new(id: 'SCSB-54321', other_id_s: ['312044'], location_code_s: ['scsbcul'], holdings_1display: holdings.to_json),
      holdings:,
      location: { code: 'scsbcul', label: 'Remote Storage' },
      mfhd: '123',
      patron: FactoryBot.build(:patron)
    )

    expect(list.to_a.length).to eq 1
    expect(list.to_a.first.barcode).to eq 'CU60224533'
    expect(list.to_a.first).to be_available
  end
end
