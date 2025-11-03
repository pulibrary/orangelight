# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../benchmark_helpers'

load_rails_classes
write_holding_locations_to_rails_cache

Benchmark.ips do |benchmark|
  benchmark.report 'BibdataService::holding_locations - reading from cache' do
    Bibdata.holding_locations
  end
end
