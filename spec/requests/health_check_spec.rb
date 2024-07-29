# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Health Check", type: :request do
  let(:solr_url) { /\/solr\/admin\/cores\?action=STATUS/ }
  let(:solr_stub) do
    stub_request(:get, 'http://www.example-solr.com:8983/solr/admin/cores?action=STATUS').to_return(
      body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
    )
  end
  let(:bibdata_url) { "https://bibdata-staging.princeton.edu/health.json" }
  let(:bibdata_stub) do
    stub_request(:get, bibdata_url).to_return(body: File.open('spec/fixtures/bibdata/health.json'))
  end
  before do
    solr_stub
    bibdata_stub
  end
  describe "GET /health" do
    it "has a health check" do
      get "/health.json"
      expect(response).to be_successful
    end

    context 'when solr is down' do
      let(:solr_stub) do
        stub_request(:get, solr_url)
          .to_return(
            body: { responseHeader: { status: 500 } }.to_json, headers: { "Content-Type" => "text/json" }
          )
      end

      before { solr_stub }

      it "errors when a service is down" do
        get "/health.json"
        expect(solr_stub).to have_been_requested
        expect(response).not_to be_successful
        expect(response.status).to eq 503
        solr_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "Solr" }
        expect(solr_response["message"]).to start_with "The solr has an invalid status"
      end
    end

    context 'when bibdata is down' do
      let(:bibdata_stub) do
        stub_request(:get, bibdata_url).to_return(status: 503, body: File.open('spec/fixtures/bibdata/bad_health.json'))
      end
      before { bibdata_stub }

      it 'errors when a service is down' do
        get "/health.json"
        expect(bibdata_stub).to have_been_requested
        expect(response).not_to be_successful
        expect(response.status).to eq 503
        bibdata_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "BibdataStatus" }
        expect(bibdata_response["message"]).to start_with "Bibdata has an invalid status"
      end
    end
  end
end
