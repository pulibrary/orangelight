# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../../../config/environment'

fixture = JSON.parse(Rails.root.join('spec/fixtures/raw/993569343506421.json').read)
bib = SolrDocument.new(fixture)

holding_data = {
  'location_code': "lewis$stacks", 'location': "Stacks", 'library': "Lewis Library", 'call_number': "QL737.U58C85", 'call_number_browse': "QL737.U58C85", 'items': [{ 'holding_id': "22699859840006421", 'id': "23699859830006421", 'status_at_load': "1", 'barcode': "32101015665811", 'copy_number': "1" }]
}
holding = Requests::Holding.new(mfhd_id: '22699859840006421', holding_data:)
item = Requests::Item.new(holding.items.first)

location = JSON.parse(Rails.root.join('spec/fixtures/holding_locations/rare_xr.json').read).with_indifferent_access

patron_hash = { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "2
2101007797777",
                "university_id" => "9999999", "patron_group" => "REG", "patron_id" => "99999", "active_email" => "foo
@princeton.edu" }.with_indifferent_access
patron = Requests::Patron.new(user: User.new, patron_hash:)

Benchmark.ips do |benchmark|
  benchmark.report 'Requestable#initialize' do
    Requests::Requestable.new(bib:, location:, item:, holding:, patron:)
  end
end
