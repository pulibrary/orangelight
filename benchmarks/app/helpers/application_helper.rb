# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../../config/environment'

view_context = CatalogController.new.view_context

Benchmark.ips do |benchmark|
  benchmark.report 'ApplicationHelper#render_location_code' do
    view_context.render_location_code 'rare$ctsn'
  end
end
