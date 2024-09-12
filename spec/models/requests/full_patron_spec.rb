# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::FullPatron, requests: true do
  it 'can be instantiated' do
    expect(described_class.new(uid: 'string')).to be
  end

  context 'with a patron' do
    let(:patron) { described_class.new(uid: 'abc123') }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:bibdata_mock) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/abc123?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})
    end

    it 'has access to errors' do
      expect(patron.errors).to match_array([])
    end

    it 'makes a call to bibdata' do
      described_class.new(uid: 'abc123')
      expect(bibdata_mock).to have_been_requested
    end
  end
end
