# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::AlmaPatron, requests: true, patrons: true do
  context 'with a call to Alma' do
    let(:uid) { 'BC123456789' }
    let(:patron_with_multiple_barcodes) { fixture('/BC123456789.json') }
    let(:alma_stub) do
      stub_request(:get, "https://api-na.hosted.exlibrisgroup.com/almaws/v1/users/#{uid}?expand=fees,requests,loans")
        .to_return(status: 200, body: patron_with_multiple_barcodes, headers: { "Content-Type" => "application/json" })
    end
    before do
      alma_stub
    end

    it 'can be instantiated' do
      described_class.new(uid:)
    end

    describe '#hash' do
      it 'has a hash' do
        expect(described_class.new(uid:).hash).to be_an_instance_of(HashWithIndifferentAccess)
      end
    end
    context 'with multiple barcodes' do
      it 'creates an access patron with the active barcode' do
        patron = described_class.new(uid:)
        expect(patron.hash[:barcode]).to eq('77777777')
        expect(alma_stub).to have_been_requested.once
      end
    end

    it 'has a patron_group' do
      patron = described_class.new(uid:)
      expect(patron.hash[:patron_group]).to eq('GST')
    end
  end
end
