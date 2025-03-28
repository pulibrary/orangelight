# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::FullPatron, requests: true, patrons: true do
  let(:user) { FactoryBot.create(:user, uid: 'abc123') }

  it 'can be instantiated' do
    expect(described_class.new(user:)).to be
  end

  context 'with a patron' do
    let(:patron) { described_class.new(user:) }
    let(:valid_patron_response) { file_fixture('../bibdata_patron_response.json') }
    let(:bibdata_mock) do
      stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/abc123?ldap=true")
        .to_return(status: 200, body: valid_patron_response, headers: {})
    end

    it 'makes a call to bibdata' do
      described_class.new(user:)
      expect(bibdata_mock).to have_been_requested
    end
  end
end
