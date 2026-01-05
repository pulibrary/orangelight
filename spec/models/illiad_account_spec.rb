# frozen_string_literal: true

require 'rails_helper'

require './lib/orangelight/illiad_patron_client.rb'
require './lib/orangelight/illiad_account.rb'

RSpec.describe Orangelight::IlliadAccount, patrons: true do
  context 'A valid Princeton User' do
    subject(:client) { described_class.new(sample_patron) }
    let(:sample_patron) do
      { 'barcode' => '2232323232323',
        'last_name' => 'smith',
        'patron_id' => '777777',
        'netid' => 'jstudent' }
    end

    let(:verify_user_response) { File.open('spec/fixtures/ill_verify_user_response.json') }
    let(:verify_user_uri) { "#{Requests.config[:illiad_api_base]}/ILLiadWebPlatform/Users/#{sample_patron['netid']}" }

    let(:verify_user_stub) do
      stub_request(:get, verify_user_uri)
        .with(
          headers: {
            'Accept' => 'application/json',
            'Apikey' => 'TESTME'
          }
        )
        .to_return(status: 200, body: verify_user_response, headers: {})
    end
    describe '#verify user' do
      before do
        verify_user_stub
      end

      it 'Returns true' do
        expect(client).to be_verify_user
      end

      it 'only calls to illiad once' do
        expect(client).to be_verify_user
        expect(client).to be_verify_user
        expect(verify_user_stub).to have_been_made.once
      end

      context 'an invalid user' do
        it 'Returns false' do
          stub_request(:get, verify_user_uri).to_return(status: 404, body: "")
          expect(client).not_to be_verify_user
        end
      end

      context 'a faraday error' do
        it 'returns false' do
          stub_request(:get, verify_user_uri).and_raise(Faraday::ConnectionFailed, "failed")
          expect(client).not_to be_verify_user
        end
      end
    end
  end
end
