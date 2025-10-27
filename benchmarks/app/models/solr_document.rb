# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../../config/environment'

locations_hash = JSON.parse(Rails.root.join('spec/fixtures/bibdata/holding_locations.json').read).to_h do |location|
  [location['code'], location.with_indifferent_access]
end.with_indifferent_access
Rails.cache.write('holding_locations', locations_hash)

# This document represents the worst case: none of the holdings are at an aeon location
fixture = JSON.parse(Rails.root.join('spec/fixtures/raw/993569343506421.json').read)
document = SolrDocument.new(fixture)

Benchmark.ips do |benchmark|
  benchmark.report { document.in_a_special_collection? }
end
