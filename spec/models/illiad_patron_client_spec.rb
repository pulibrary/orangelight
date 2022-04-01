# frozen_string_literal: true

require 'rails_helper'

require './lib/orangelight/illiad_patron_client.rb'
require './lib/orangelight/illiad_account.rb'

RSpec.describe IlliadPatronClient do
  context 'A valid Princeton User' do
    sample_patron = { 'barcode' => '2232323232323',
                      'last_name' => 'smith',
                      'patron_id' => '777777',
                      'netid' => 'jstudent' }
    subject(:client) { described_class.new(sample_patron) }
    let(:cancel_ill_requests_response) { File.open(fixture_path + '/cancel_ill_requests_response.json') }
    let(:outstanding_ill_requests_response) { File.open(fixture_path + '/outstanding_ill_requests_response.json') }
    let(:params_cancel_requests) { ['1093597'] }
    let(:current_ill_requests_uri) do
      "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Transaction/UserRequests/#{sample_patron['netid']}?$filter=" \
       "ProcessType%20eq%20'Borrowing'%20and%20TransactionStatus%20ne%20'Request%20Finished'%20and%20not%20startswith%28TransactionStatus,'Cancelled'%29"
    end

    describe '#outstanding_ill_requests' do
      before do
        stub_request(:get, current_ill_requests_uri)
          .with(
            headers: {
              'Accept' => 'application/json',
              'Apikey' => 'TESTME'
            }
          )
          .to_return(status: 200, body: outstanding_ill_requests_response, headers: {})
      end

      it 'Returns a successful http response' do
        requests = client.outstanding_ill_requests
        expect(requests.count).to eq(2)
        expect(requests.first["PhotoJournalTitle"]).to eq("Pʹesy")
        expect(requests.first["PhotoArticleAuthor"]).to eq("Chekhov, Anton Pavlovich")
      end

      context 'a faraday error' do
        it 'returns false' do
          stub_request(:get, current_ill_requests_uri).and_raise(Faraday::ConnectionFailed, "failed")
          expect(client.outstanding_ill_requests.count).to eq(0)
        end
      end
    end

    describe '#cancel_ill_requests' do
      before do
        cancel_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/transaction/#{params_cancel_requests[0]}/route"
        stub_request(:put, cancel_ill_requests_uri)
          .with(
            headers: {
              'Apikey' => 'TESTME'
            },
            body: "{\"Status\":\"Cancelled by Customer\"}"
          )
          .to_return(status: 200, body: cancel_ill_requests_response, headers: {})
      end

      it 'Cancels an ILLiad transaction' do
        responses = client.cancel_ill_requests(params_cancel_requests)
        expect(responses.first).to be_a(Faraday::Response)
        expect(responses.first.status).to eq(200)
      end
    end
  end
end
