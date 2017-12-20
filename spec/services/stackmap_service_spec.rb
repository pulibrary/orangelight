require 'rails_helper'

RSpec.describe StackmapService::Url do
  subject { described_class.new(document: document, loc: location, cn: call_number).url }

  let(:document) { SolrDocument.new(properties) }
  let(:call_number) { nil }
  let(:properties) do
    {
      id: '1234567',
      title_display: 'Title',
      call_number_browse_s: ['doc call number']
    }
  end

  before { stub_holding_locations }

  describe '#url with valid params' do
    describe 'firestone, call number provided' do
      let(:location) { 'f' }
      let(:call_number) { 'Q43.2' }

      it 'resolves to firestone locator with loc and bibid' do
        expect(subject).to eq("https://library.princeton.edu/locator/index.php?loc=#{location}&id=#{properties[:id]}")
      end
    end
    describe 'firestone, no call number provided' do
      let(:location) { 'f' }

      it 'resolves to firestone locator with loc and bibid' do
        expect(subject).to eq("https://library.princeton.edu/locator/index.php?loc=#{location}&id=#{properties[:id]}")
      end
    end
    describe 'mendel, call number provided' do
      let(:location) { 'mus' }
      let(:call_number) { 'Q43.2' }

      it 'resolves to stackmap with provided call number' do
        expect(subject).to include('princeton.stackmap')
        expect(subject).to include(call_number)
      end
    end
    describe 'mendel, no call number provided' do
      let(:location) { 'mus' }

      it 'resolves to stackmap with document call number' do
        expect(subject).to include('princeton.stackmap')
        expect(subject).to include({ callno: properties[:call_number_browse_s].first }.to_query)
      end
    end
    describe 'by title location' do
      let(:location) { 'sprps' }

      it 'uses title as the call number value' do
        expect(subject).to include({ callno: properties[:title_display] }.to_query)
      end
    end
    describe 'non-stackmap location' do
      let(:location) { 'pplr' }

      it 'resolves to branch library page' do
        expect(subject).to eq('https://library.princeton.edu/plasma-physics')
      end
    end
  end
  describe '#url with invalid params' do
    describe 'invalid location code' do
      let(:location) { 'not-a-location' }

      it 'resolves to catalog show page url' do
        expect(subject).to include("/catalog/#{properties[:id]}")
      end
    end
    describe 'nil location' do
      let(:location) { nil }

      it 'resolves to catalog show page url' do
        expect(subject).to include("/catalog/#{properties[:id]}")
      end
    end
    describe 'missing doc' do
      let(:location) { 'f' }
      let(:document) { nil }

      it 'resolves to catalog homepage' do
        expect(subject).to match(%r{catalog/$})
      end
    end
  end
end
