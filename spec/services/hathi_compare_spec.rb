# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HathiCompare do
  let(:hathi_compare) { described_class.new(solr_base_url: "http://localhost:8888/solr/orangelight-core-test/select?fl=id%2C%20oclc_s&q=oclc_s%3A*&rows=20") }
  it 'loads the Hathi Pul Matches' do
    expect do
      hathi_compare.load_hathi_compare(hathi_file: 'spec/fixtures/overlap_20200316_princetona_part1.tsv')
    end.to change { HathiPulMatch.count }.by(99)
  end

  it 'compares solr with matches' do
    stub_hathi
    hathi_compare.load_hathi_compare(hathi_file: 'spec/fixtures/overlap_20200316_princetona_part1.tsv')
    unmatched_results, matched_results = hathi_compare.process_solr_query(max: 77, rows: 20)
    expect(unmatched_results.count).to eq(76)
    expect(matched_results).to eq(1)
  end
end
