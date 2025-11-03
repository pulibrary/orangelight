# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../benchmark_helpers'

load_rails_classes
write_holding_locations_to_rails_cache

# This document represents the worst case: none of the holdings are at an aeon location
document = solr_doc_from_fixture_file 'spec/fixtures/raw/993569343506421.json'

Benchmark.ips do |benchmark|
  benchmark.report('SolrDocument#in_a_special_collection?') { document.in_a_special_collection? }
end
