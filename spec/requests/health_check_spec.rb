# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Health Check", type: :request do
  let(:solr_url) { /\/solr\/admin\/cores\?action=STATUS/ }
  let(:solr_stub) do
    stub_request(:get, 'http://www.example-solr.com:8983/solr/admin/cores?action=STATUS').to_return(
      body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
    )
  end
  let(:bibdata_url) { "https://bibdata-staging.lib.princeton.edu/health.json" }
  let(:bibdata_stub) do
    stub_request(:get, bibdata_url).to_return(body: File.open('spec/fixtures/bibdata/health.json'))
  end
  let(:illiad_url) { "https://lib-illiad.princeton.edu/IlliadWebPlatform/SystemInfo/PlatformVersion" }
  let(:illiad_stub) do
    stub_request(:get, illiad_url).to_return(body: "ILLiad Platform Version: 9.2.2.0", status: 200)
  end
  let(:aeon_url) { "https://princeton.aeon.atlas-sys.com/aeon/api/SystemInformation/Version" }
  let(:aeon_stub) do
    stub_request(:get, aeon_url).to_return(body: "1.5.2.0", status: 200)
  end
  let(:stackmap_url) { "https://www.stackmapintegration.com/princeton-blacklight/StackMap.min.js" }
  let(:stackmap_stub) do
    stub_request(:head, stackmap_url).to_return(status: 200)
  end
  let(:scsb_url) { "https://scsb.recaplib.org:9093" }
  let(:scsb_stub) do
    stub_request(:get, scsb_url).to_return(status: 200)
  end
  before do
    solr_stub
    bibdata_stub
    illiad_stub
    aeon_stub
    stackmap_stub
    scsb_stub
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

      it 'has error but does not show as down when bibdata is down' do
        get "/health.json"
        expect(bibdata_stub).to have_been_requested
        expect(response).to be_successful
        expect(response.status).to eq 200
        bibdata_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "BibdataStatus" }
        expect(bibdata_response["message"]).to start_with "Bibdata has an invalid status"
      end
    end

    context 'when illiad is down' do
      let(:illiad_stub) do
        stub_request(:get, illiad_url).to_return(status: 500)
      end
      before { illiad_stub }

      it 'has error but does not show as down when illiad is down' do
        get "/health.json"
        expect(illiad_stub).to have_been_requested
        expect(response).to be_successful
        expect(response.status).to eq 200
        illiad_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "IlliadStatus" }
        expect(illiad_response["message"]).to start_with "Illiad has an invalid status"
      end
    end

    context 'when aeon is down' do
      let(:aeon_stub) do
        stub_request(:get, aeon_url).to_return(status: 500)
      end
      before { aeon_stub }

      it 'has error but does not show as down when aeon is down' do
        get "/health.json"
        expect(aeon_stub).to have_been_requested
        expect(response).to be_successful
        expect(response.status).to eq 200
        aeon_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "AeonStatus" }
        expect(aeon_response["message"]).to start_with "Aeon has an invalid status"
      end
    end

    context 'when stackmap is down' do
      let(:stackmap_stub) do
        stub_request(:head, stackmap_url).to_return(status: 404)
      end
      before { stackmap_stub }

      it 'has error but does not show as down when stackmap is down' do
        get "/health.json"
        expect(stackmap_stub).to have_been_requested
        expect(response).to be_successful
        expect(response.status).to eq 200
        stackmap_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "StackmapStatus" }
        expect(stackmap_response["message"]).to start_with "Stackmap has an invalid status"
      end
    end

    context 'when scsb is down' do
      let(:scsb_stub) do
        stub_request(:get, scsb_url).to_return(status: 500)
      end
      before { scsb_stub }

      it 'has error but does not show as down when scsb is down' do
        get "/health.json"
        expect(scsb_stub).to have_been_requested
        expect(response).to be_successful
        expect(response.status).to eq 200
        scsb_response = JSON.parse(response.body)["results"].find { |x| x["name"] == "ScsbStatus" }
        expect(scsb_response["message"]).to start_with "SCSB has an invalid status"
      end
    end
  end
end
