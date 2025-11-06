# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../../benchmark_helpers'

load_rails_classes

bib = solr_doc_from_fixture_file 'spec/fixtures/raw/993569343506421.json'
mfhd_id = '22693661550006421'
location = JSON.parse(Rails.root.join('spec/fixtures/holding_locations/plasma_nb.json').read)
holding_data = JSON.parse(bib[:holdings_1display])[mfhd_id]
holding = Requests::Holding.new(mfhd_id:, holding_data:)
item = Requests::Item.new(holding.items.first)
patron = Requests::Patron.new(patron_hash: {}, user: User.new)

view_context = Requests::FormController.new.view_context
requestable_decorator = Requests::RequestableDecorator.new(
  Requests::Requestable.new(bib:, holding:, item:, location:, patron:),
  view_context
)

Benchmark.ips do |benchmark|
  benchmark.report 'Requests::ItemHiddenFieldsComponent' do
    view_context.render Requests::ItemHiddenFieldsComponent.new(requestable_decorator)
  end
end
