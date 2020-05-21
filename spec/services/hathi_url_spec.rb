# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HathiUrl do
  let(:hathi_base_url) { 'https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=https://idp.princeton.edu/idp/shibboleth&target=https%3A%2F%2Fbabel.hathitrust.org%2Fcgi%2Fpt%3Fid%3D' }
  before do
    stub_hathi
  end

  context 'with a valid oclc number' do
    let(:oclc_id) { '42579288' }
    it 'returns hathi item url' do
      hathi_url = described_class.new(oclc_id: oclc_id)
      expect(hathi_url.url).to eq("#{hathi_base_url}mdp.39015047450062")
    end
  end

  context 'with a valid hathi identifier' do
    let(:hathi_identifier) { 'mdp.39015047450062' }
    it 'returns hathi item url' do
      hathi_url = described_class.new(oclc_id: nil, hathi_identifier: hathi_identifier)
      expect(hathi_url.url).to eq("#{hathi_base_url}mdp.39015047450062")
    end
  end

  context 'with a valid oclc number, but multiple exception' do
    let(:oclc_id) { '42579288' }
    it 'returns nil' do
      allow(JSON).to receive(:parse).and_raise JSON::ParserError
      hathi_url = described_class.new(oclc_id: oclc_id, maximum_retries: 1, sleep_duration: 0.5)
      expect(hathi_url.url).to be_nil
    end
  end

  context 'with a valid oclc number, but an exception' do
    let(:oclc_id) { '42579288' }
    it 'returns hathi item url' do
      first = true
      allow(JSON).to receive(:parse).and_wrap_original do |m, *args|
        if first
          first = false
          raise JSON::ParserError
        else
          m.call(*args)
        end
      end
      hathi_url = described_class.new(oclc_id: oclc_id, maximum_retries: 1, sleep_duration: 0.5)
      expect(hathi_url.url).to eq("#{hathi_base_url}mdp.39015047450062")
    end
  end

  context 'with an invalid oclc number' do
    let(:oclc_id) { '42579288x' }
    it 'returns nil' do
      hathi_url = described_class.new(oclc_id: oclc_id)
      expect(hathi_url.url).to be_nil
    end
  end
end
