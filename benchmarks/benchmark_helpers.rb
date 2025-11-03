# frozen_string_literal: true
def load_rails_classes
  require_relative '../config/environment'
end

def write_holding_locations_to_rails_cache
  locations_hash = JSON.parse(Rails.root.join('spec/fixtures/bibdata/holding_locations.json').read).to_h do |location|
    [location['code'], location.with_indifferent_access]
  end
  Rails.cache.write('holding_locations', locations_hash)
end

def solr_doc_from_fixture_file(_filepath)
  fixture = JSON.parse(Rails.root.join('spec/fixtures/raw/993569343506421.json').read)
  SolrDocument.new(fixture)
end

def print_allocations(benchmark_name)
  GC.disable
  objects_before = ObjectSpace.each_object.count
  yield
  objects_after = ObjectSpace.each_object.count
  GC.enable
  # rubocop:disable Rails/Output
  puts "#{benchmark_name}: #{objects_after - objects_before} objects allocated\n"
  # rubocop:enable Rails/Output
end
