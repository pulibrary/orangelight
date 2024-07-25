# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuthToken do
  describe '#token' do
    context 'when an unexpired token is already in the database' do
      before do
        described_class.create(service: 'libanswers', endpoint: 'http://my-api.com', token: 'valid-token',
                               expiration_time: Time.utc(2050, 1, 1, 10, 30, 59))
      end

      it 'returns the token from the database' do
        travel_to Date.new(2020, 1, 1)
        entry = described_class.find_by(endpoint: 'http://my-api.com')
        expect(entry.token).to eq('valid-token')
      end
    end

    context 'when an expired token is in the database' do
      before do
        described_class.create(service: 'libanswers', endpoint: 'http://my-api.com', token: 'expired-token',
                               expiration_time: Time.utc(1995, 1, 1, 10, 30, 59))
      end

      it 'fetches a new token from the endpoint' do
        stub_request(:post, 'http://my-api.com')
          .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
          .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
        travel_to Date.new(2020, 1, 1)
        entry = described_class.find_by(endpoint: 'http://my-api.com')
        expect(entry.token).to eq('abcdef1234567890abcdef1234567890abcdef12')
        expect(entry.expiration_time).to eq(Time.zone.local(2020, 1, 7, 23, 0, 0))
      end
    end

    context 'when there is not yet a token or expiration_time in the database' do
      before do
        described_class.create(service: 'libanswers', endpoint: 'http://my-api.com')
      end

      it 'fetches a new token from the endpoint' do
        stub_request(:post, 'http://my-api.com')
          .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
          .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
        travel_to Date.new(2020, 1, 1)
        entry = described_class.find_by(endpoint: 'http://my-api.com')
        expect(entry.token).to eq('abcdef1234567890abcdef1234567890abcdef12')
        expect(entry.expiration_time).to eq(Time.zone.local(2020, 1, 7, 23, 0, 0))
      end
    end
  end
end
