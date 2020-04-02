# frozen_string_literal: true
require 'csv'

class HathiCompare
  attr_reader :solr_base_url
  def initialize(solr_base_url: "http://localhost:9000/solr/catalog-staging/select?fl=id%2C%20oclc_s&q=oclc_s%3A*")
    @solr_base_url = solr_base_url
  end
  # rubocop:enable Lint/UnusedMethodArgument

  def load_hathi_compare(hathi_file: "/Users/colec/Downloads/overlap_20200316_princeton.tsv")
    ::CSV.foreach(hathi_file, col_sep: "\t", headers: true) do |row|
      data = row.to_h
      id = data.delete("local_id")
      HathiPulMatch.new(data.merge(pul_id: id)).save
    end
  end

  def process_solr_query(max: 5_435_394, rows: 200, start: 0)
    unmatched_results = []
    matched_results = 0
    while start < max
      umatch, match = process_data(start: start, rows: rows)
      unmatched_results << umatch
      matched_results += match
      start += rows
      unmatched_results = unmatched_results.flatten
      Rails.logger.info "processed #{start} results unmatched: #{unmatched_results.count} matched: #{matched_results} ratio matched #{matched_results / start.to_f} "\
                        "ratio unmatched #{unmatched_results.count / start.to_f}\n\n\n**** Unmatched ***\n#{umatch}\n\n"
    end
    [unmatched_results, matched_results]
  end

  private

    def process_data(start:, rows:)
      matched_results = 0
      unmatched_results = []
      solr_data = query_solr(start: start, rows: rows)
      Rails.logger.info "doc count = #{solr_data['response']['docs'].count}"
      solr_data["response"]["docs"].each do |doc|
        oclc = doc["oclc_s"].first
        next if oclc.blank?
        url = hathi_url(oclc: oclc)
        matched_results = check_oclc_hathi_match(oclc: oclc, unmatched_results: unmatched_results, matched_results: matched_results) if url.present?
      end
      [unmatched_results, matched_results]
    end

    def hathi_url(oclc:)
      url = nil
      begin
        url = HathiUrl.new(oclc_id: oclc, lccn: nil, isbn: nil).url
      rescue JSON::ParserError => e
        Rails.logger.warn e
        sleep 30
        retry
      end
      url
    end

    def check_oclc_hathi_match(oclc:, unmatched_results:, matched_results:)
      match = HathiPulMatch.find_by(oclc: oclc)
      if match.blank?
        unmatched_results << oclc
      else
        matched_results +=1
      end
      matched_results
    end

    def query_solr(start:, rows:)
      uri = URI("#{solr_base_url}&start=#{start}&format=json&rows=#{rows}")
      json_data = Net::HTTP.get(uri)
      JSON.parse(json_data)
    end
end
