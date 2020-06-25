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

    describe '#outstanding_ill_requests' do
      before do
        ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
        outstanding_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Transaction/UserRequests/#{sample_patron['netid']}?$filter=TransactionStatus%20ne%20'Cancelled%20by%20ILL%20Staff'"
        stub_request(:get, outstanding_ill_requests_uri)
          .to_return(status: 200, body: outstanding_ill_requests_response, headers: {
                       'Accept' => 'application/json',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Apikey' => 'TESTME'
                     })
      end

      it 'Returns a successful http response' do
        expect(client.outstanding_ill_requests).to be_a(Faraday::Response)
        expect(client.outstanding_ill_requests.status).to eq(200)
      end
    end

    describe '#cancel_ill_requests' do
      before do
        ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
        cancel_ill_requests_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/transaction/#{params_cancel_requests[0]}/route"
        stub_request(:put, cancel_ill_requests_uri)
          .with(body: "{\"Status\":\"Cancelled by Customer\"}")
          .to_return(status: 200, body: cancel_ill_requests_response, headers: {
         	  'Content-Type'=>'application/json',
         	  'Apikey'=>'TESTME'
             })
      end

      it 'Cancels an ILLiad transaction' do
        expect(client.cancel_ill_requests(params_cancel_requests)).to be_a(Faraday::Response)
        expect(client.cancel_ill_requests(params_cancel_requests).status).to eq(200)
      end
    end
  end
end
