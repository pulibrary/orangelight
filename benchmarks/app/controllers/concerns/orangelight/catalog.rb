# frozen_string_literal: true
require 'benchmark/ips'
require 'objspace'
require_relative '../../../../benchmark_helpers'

load_rails_classes
document = solr_doc_from_fixture_file 'spec/fixtures/raw/9933643713506421_raw.json'

# rubocop:disable Style/MixinUsage
include Orangelight::Catalog
# rubocop:enable Style/MixinUsage

Benchmark.ips do |benchmark|
  benchmark.report('Orangelight::Catalog::show_location_has?') { show_location_has?(nil, document) }
end

print_allocations('Orangelight::Catalog::show_location_has?') { show_location_has?(nil, document) }
