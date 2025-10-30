# frozen_string_literal: true
require 'benchmark/ips'
require_relative '../../../../../config/environment'

fixture = JSON.parse(Rails.root.join('spec/fixtures/raw/993569343506421.json').read)
document = SolrDocument.new(fixture)

controller = Requests::FormController.new
controller.action_name = 'form'
controller.request = ActionDispatch::Request.empty
view_context = controller.view_context

Benchmark.ips do |benchmark|
  benchmark.report do
    view_context.render partial: 'show_basic_metadata', locals: { document: }
  end
end
