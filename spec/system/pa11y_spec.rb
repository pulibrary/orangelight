# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'pa11y' do
  let(:bibs) { ["994264203506421", "994916543506421", "9928379683506421", "9961023373506421", "9976174773506421"] }
  before do
    $port = rand(9000..9999)
    stub_alma_holding_locations
    $rails_server = spawn("bundle exec rails s -p #{$port}")
    Process.detach($rails_server)
  end

  after do
    Process.kill('TERM', $rails_server)
    `rm tmp/pids/server.pid`
  end

  it 'passes pa11y' do
    bibs.each do |bib|
      results = `yarn pa11y http://localhost:#{$port}/catalog/#{bib}`
      expect(results).to include('No issues found!'), bib
    end
  end
end
