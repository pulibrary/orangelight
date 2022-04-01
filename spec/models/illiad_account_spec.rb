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
    let(:verify_user_uri) { "#{ENV['ILLIAD_API_BASE_URL']}/ILLiadWebPlatform/Users/#{sample_patron['netid']}" }

    describe '#verify user' do
      before do
        stub_request(:get, verify_user_uri)
          .with(
            headers: {
              'Accept' => 'application/json',
              'Apikey' => 'TESTME'
            }
          )
          .to_return(status: 200, body: verify_user_response, headers: {})
      end

      it 'Returns true' do
        expect(client.verify_user).to be_truthy
      end

      context 'an invalid user' do
        it 'Returns false' do
          stub_request(:get, verify_user_uri).to_return(status: 404, body: "")
          expect(client.verify_user).to be_falsy
        end
      end

      context 'a faraday error' do
        it 'returns false' do
          stub_request(:get, verify_user_uri).and_raise(Faraday::ConnectionFailed, "failed")
          expect(client.verify_user).to be_falsy
        end
      end
    end
  end
end
