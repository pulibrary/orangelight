# frozen_string_literal: true

require 'rails_helper'

require './lib/orangelight/illiad_patron_client.rb'
require './lib/orangelight/illiad_account.rb'

RSpec.describe IlliadAccount do
  context 'A valid Princeton User' do
    sample_patron = { 'barcode' => '2232323232323',
                      'last_name' => 'smith',
                      'patron_id' => '777777',
                      'netid' => 'jstudent' }
    subject(:client) { described_class.new(sample_patron) }
    let(:verify_user_response) { File.open(fixture_path + '/ill_verify_user_response.json') }

    describe '#verify user' do
      before do
        ENV['ILLIAD_API_BASE_URL'] = "http://illiad.com"
        verify_user_uri = "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/#{sample_patron['netid']}"
        stub_request(:get, verify_user_uri)
          .to_return(status: 200, body: verify_user_response, headers: {
                       'Accept' => 'application/json',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Apikey' => 'TESTME'
                     })
      end

      it 'Returns a successful http response' do
        expect(client.verify_user).to be_a(Faraday::Response)
        expect(client.verify_user.status).to eq(200)
      end
    end
  end
end
