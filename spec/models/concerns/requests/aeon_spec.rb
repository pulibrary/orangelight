# frozen_string_literal: true
require 'rails_helper'

# A class double that includes the described module
class ObjectWithAeon
  include Requests::Aeon
  attr_accessor :bib
  delegate :enumerated?, to: :item
  def initialize(bib)
    @bib = bib
  end

  def holding
    { "22740186070006421" => { "items" => [{ "holding_id" => "22740186070006421", "id" => "23740186060006421" }] } }
  end

  def item
    @item ||= Requests::Requestable::Item.new({ 'id' => "13579", 'barcode' => '24680' }.with_indifferent_access)
  end
end

describe Requests::Aeon do
  let(:bib) { SolrDocument.new({ id: '1234', holdings_1display: '{"123": {"barcode": "24680"}}' }) }
  subject { ObjectWithAeon.new(bib) }
  let(:location) do
    { "code" => "rare$xc", "aeon_location" => true, "library" => { "code" => "rare" }, "holding_library" => { "code" => "rare" } }
  end
  before do
    allow(subject).to receive(:location).and_return(location)
  end
  describe '#aeon_basic_params' do
    it 'takes its ReferenceNumber from the bib MMS ID' do
      expect(subject.aeon_basic_params[:ReferenceNumber]).to eq('1234')
    end
  end
  describe '#aeon_openurl' do
    context 'when bib record is not a constituent' do
      it 'takes its ItemNumber from the holdings1_display' do
        expect(subject.aeon_openurl(OpenURL::ContextObject.new)).to include('ItemNumber=24680')
      end
    end
    context 'when bib record is a constituent' do
      let(:bib) { SolrDocument.new({ id: '1234', contained_in_s: ['9999'] }) }
      it 'takes its ItemNumber from the host record barcode' do
        allow(bib).to receive(:doc_by_id) { { 'holdings_1display' => '{"1":{"barcode":"33_host_barcode"}}' } }
        expect(subject.aeon_openurl(OpenURL::ContextObject.new)).to include('ItemNumber=33_host_barcode')
      end
    end
  end
end
