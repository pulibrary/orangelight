# frozen_string_literal: true
require 'rails_helper'
require 'orangelight/browse_lists'
require 'orangelight/browse_lists/call_number_csv'

RSpec.describe BrowseLists::CallNumberCSV do
  describe "#write" do
    let(:output_root) { Rails.root.join("tmp", "spec") }

    before do
      FileUtils.mkdir_p(output_root)
      allow(described_class).to receive(:output_root).and_return(output_root)

      WebMock.disable_net_connect!

      stub_request(
        :get, "http://127.0.0.1:8888/solr/orangelight-core-test/select?defType=edismax&facet.field=call_number_browse_s&facet.limit=-1&facet.mincount=2&facet.sort=asc&fl=id&indent=true&q=*:*&wt=json"
      )
        .to_return(status: 200, body: file_fixture("call_number_browse/multi_call_numbers.json"), headers: {})

      stub_request(:get, "http://127.0.0.1:8888/solr/orangelight-core-test/select?defType=edismax&fl=id&indent=true&q=*:*&wt=json")
        .to_return(status: 200, body: file_fixture("call_number_browse/index_count.json"), headers: {})

      stub_request(
        :get, "http://127.0.0.1:8888/solr/orangelight-core-test/select?defType=edismax&facet=false&fl=call_number_browse_s,title_display,title_vern_display,author_display,author_s,id,pub_created_vern_display,pub_created_display,holdings_1display&indent=true&q=*:*&rows=500&sort=id%20asc&start=0&wt=json"
      )
        .to_return(status: 200, body: file_fixture("call_number_browse/index_entries_rows500_start0.json"), headers: {})

      stub_request(
        :get, "http://127.0.0.1:8888/solr/orangelight-core-test/select?defType=edismax&facet=false&fl=call_number_browse_s,title_display,title_vern_display,author_display,author_s,id,pub_created_vern_display,pub_created_display,holdings_1display&indent=true&q=*:*&rows=500&sort=id%20asc&start=500&wt=json"
      )
        .to_return(status: 200, body: file_fixture("call_number_browse/index_entries_rows500_start500.json"), headers: {})
    end

    after do
      # reset webmock according to spec_helper
      WebMock.disable_net_connect!(
        allow_localhost: true,
        allow: 'chromedriver.storage.googleapis.com'
      )
      # delete the test csv from tmp
      FileUtils.remove_file(output_root, true)
    end

    it "generates a csv" do
      _sql_command, facet_request, conn = BrowseLists.connection
      described_class.new(facet_request, conn, output_root, rows: 500).write

      csv_file = output_root.join("call_number_browse_s.csv")
      expect(File.exist?(csv_file)).to be true
      expect(File.read(csv_file).scan(/\n/).count).to eq 496_049
    end

    context "when solr returns a hash with no response key" do
      before do
        allow(Rails.logger).to receive(:error)
        stub_request(
          :get, "http://127.0.0.1:8888/solr/orangelight-core-test/select?defType=edismax&facet=false&fl=call_number_browse_s,title_display,title_vern_display,author_display,author_s,id,pub_created_vern_display,pub_created_display,holdings_1display&indent=true&q=*:*&rows=500&sort=id%20asc&start=0&wt=json"
        )
          .to_return(status: 200, body: {}.to_json, headers: {})
      end

      it "logs the failure and retries twice before erroring" do
        _sql_command, facet_request, conn = BrowseLists.connection
        expect do
          described_class.new(facet_request, conn, output_root, rows: 500).write
        end.to raise_error(BrowseLists::SolrResponseError)
        expect(Rails.logger).to have_received(:error).exactly(3).times
      end
    end
  end
end
