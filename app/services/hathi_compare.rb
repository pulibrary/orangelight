# frozen_string_literal: true
require 'csv'

class HathiCompare
  attr_reader :solr_base_url


  # rubocop:disable Lint/UnusedMethodArgument
  def initialize(solr_base_url: "http://localhost:9000/solr/catalog-staging/select?fl=id%2C%20oclc_s&q=oclc_s%3A*" )
    @solr_base_url = solr_base_url
  end
  # rubocop:enable Lint/UnusedMethodArgument

  def load_hathi_compare(hathi_file: "/Users/colec/Downloads/overlap_20200316_princeton.tsv")
    ::CSV.foreach(hathi_file,{ :col_sep => "\t", headers: true }) do |row|
      data= row.to_h
      id = data.delete("local_id")
      HathiPulMatch.new(data.merge(pul_id: id)).save
    end
  end

  def process_solr_query(max: 5435394, rows: 200)
    unmatched_results = []
    matched_results = []
    start = 0
    while(start< max) do
      umatch, match = process_data(start: start)
      unmatched_results << umatch
      matched_results << match
      start +=20
      unmatched_results= unmatched_results.flatten
      matched_results= matched_results.flatten
      puts "processed #{start} results unmatched: #{unmatched_results.count} matched: #{matched_results.count} ratio matched #{matched_results.count/start.to_f} ratio unmatched #{unmatched_results.count/start.to_f}"
    end
    [unmatched_results, matched_results]
  end

  private
    def process_data(start: 0)
      unmatched_results = []
      matched_results = []
      solr_data = query_solr(start: start)
      solr_data["response"]["docs"].each do |doc|
        oclc = doc["oclc_s"].first
        url = HathiUrl.new(oclc_id: oclc, lccn: nil, isbn: nil)
        if (url.present?)
          match = HathiPulMatch.find_by(oclc: oclc)
          if match.blank?
            unmatched_results << oclc 
          else
            matched_results << oclc
          end
        end
      end
      [unmatched_results, matched_results]
    end

    def query_solr(start: 0, rows: 2000)
      uri = URI("#{solr_base_url}&start=#{start}&format=json&rows=#{rows}")
      json_data = Net::HTTP.get(uri)
      JSON.parse(json_data)
    end
end
