# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EzProxyService do
  describe "#ez_proxy_url?" do
    context 'with a well-formed non-ezproxy url' do
      let(:url) { 'http://test.com' }

      it 'identifies that it is not an ezproxy url' do
        expect(described_class.ez_proxy_url?(url)).to eq(false)
      end
    end

    context 'with a well-formed ezproxy url' do
      let(:url) { 'http://gateway.proquest.com/long-path-etc' }

      it 'identifies it as an ezproxy url' do
        expect(described_class.ez_proxy_url?(url)).to eq(true)
      end
    end

    context 'with an ezproxy url as a symbol' do
      let(:url) { :'http://gateway.proquest.com/long-path-etc' }

      it 'identifies it as an ezproxy url' do
        expect(described_class.ez_proxy_url?(url)).to eq(true)
      end
    end

    context 'when given an ip address' do
      let(:url) { 'http://198.61.255.241/url' }

      it 'identifies it as an ezproxy url' do
        expect(described_class.ez_proxy_url?(url)).to eq(true)
      end
    end

    context 'when given a non-url' do
      let(:non_url) { 'just a string' }

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it 'identifies that it is not an ezproxy url' do
        expect(described_class.ez_proxy_url?(non_url)).to eq(false)
      end

      it 'logs an error' do
        described_class.ez_proxy_url?(non_url)
        expect(Rails.logger).to have_received(:warn).with("EzProxyService encountered bad url: just a string")
      end
    end
  end

  describe "#ez_proxy_url(url)" do
    context 'with a well-formed non-ezproxy url' do
      let(:url) { 'http://test.com' }

      it 'identifies that it is not an ezproxy url' do
        expect(described_class.ez_proxy_url(url)).to eq(url)
      end
    end

    context 'with a well-formed ezproxy url' do
      let(:url) { 'http://gateway.proquest.com/long-path-etc' }

      it 'identifies it as an ezproxy url' do
        expect(described_class.ez_proxy_url(url)).to eq('https://login.ezproxy.princeton.edu/login?url=http://gateway.proquest.com/long-path-etc')
      end
    end

    context 'with an ezproxy url as a symbol' do
      let(:url) { :'http://gateway.proquest.com/long-path-etc' }

      it 'returns the url as a string' do
        expect(described_class.ez_proxy_url(url)).to eq('https://login.ezproxy.princeton.edu/login?url=http://gateway.proquest.com/long-path-etc')
      end
    end

    context 'with a non-ezproxy url as a symbol' do
      let(:url) { :'http://test.com' }

      it 'returns the url as a string' do
        expect(described_class.ez_proxy_url(url)).to eq('http://test.com')
      end
    end
  end
end
