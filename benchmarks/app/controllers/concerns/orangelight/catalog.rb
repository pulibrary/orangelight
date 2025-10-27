# frozen_string_literal: true
require 'benchmark/ips'
require 'objspace'
require_relative '../../../../../config/environment'

fixture = JSON.parse(Rails.root.join('spec/fixtures/raw/9933643713506421_raw.json').read)
document = SolrDocument.new(fixture)

def print_allocations
  GC.disable
  objects_before = ObjectSpace.each_object.count
  yield
  objects_after = ObjectSpace.each_object.count
  GC.enable
  # rubocop:disable Rails/Output
  puts "#{objects_after - objects_before} objects allocated"
  # rubocop:enable Rails/Output
end

# rubocop:disable Style/MixinUsage
include Orangelight::Catalog
# rubocop:enable Style/MixinUsage

Benchmark.ips do |benchmark|
  benchmark.report { show_location_has?(nil, document) }
end

print_allocations { show_location_has?(nil, document) }
