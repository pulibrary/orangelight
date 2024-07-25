# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OAuthService do
  before do
    stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
      .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
      .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
  end

  describe '#new_token' do
    it 'gets a new token from the OAuth server' do
      service = described_class.new(endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token',
                                    service: :libanswers)
      expect(service.new_token).to eq('abcdef1234567890abcdef1234567890abcdef12')
    end
  end

  describe '#expiration_time' do
    it 'gets an expiration time for the new token, then adds an hour of padding' do
      travel_to Time.utc(2000, 1, 1, 0, 0, 0)
      service = described_class.new(endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token',
                                    service: :libanswers)
      expect(service.expiration_time).to eq(Time.utc(2000, 1, 7, 23, 0, 0))
    end

    it 'does not make an additional call if you already called #new_token' do
      service = described_class.new(endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token',
                                    service: :libanswers)
      service.new_token
      service.expiration_time
      expect(WebMock).to have_requested(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token').once
    end
  end
end
