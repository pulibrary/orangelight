# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StackmapService::Url do
  subject(:url) { url_service.url }

  let(:url_service) { described_class.new(document: document, loc: location, cn: call_number) }
  let(:document) { SolrDocument.new(properties) }
  let(:doc_cn) { ['doc call number'] }
  let(:call_number) { nil }
  let(:properties) do
    {
      id: '1234567',
      title_display: 'Title',
      call_number_browse_s: doc_cn
    }
  end

  before { stub_holding_locations }

  describe '#url with valid params' do
    describe 'firestone, call number provided' do
      let(:location) { 'firestone$stacks' }
      let(:call_number) { 'Q43.2' }

      context 'with firestone_locator on' do
        before do
          allow(Flipflop).to receive(:firestone_locator?).and_return(true)
        end
        it 'resolves to embeded firestone locator with loc and bibid' do
          expect(url).to eq("https://locator-prod.princeton.edu/index.php?loc=#{location}&id=#{properties[:id]}&embed=true")
        end

        context 'when firestone_locator_base_url points to the staging locator' do
          before do
            allow(Orangelight.config).to receive(:[]).with('firestone_locator_base_url')
                                                     .and_return('https://locator-staging.princeton.edu')
          end
          it 'resolves to embeded staging firestone locator with loc and bibid' do
            expect(url).to eq("https://locator-staging.princeton.edu/index.php?loc=#{location}&id=#{properties[:id]}&embed=true")
          end
        end
      end
      context 'with firestone_locator off' do
        before do
          allow(Flipflop).to receive(:firestone_locator?).and_return(false)
        end
        it 'resolves to external stackmap service' do
          expect(url).to eq("https://princeton.stackmap.com/view/?callno=Q43.2&library=Firestone+Library&location=firestone%24stacks")
        end
      end
    end
    describe 'firestone, no call number provided' do
      let(:location) { 'firestone$stacks' }

      it 'resolves to embeded firestone locator with loc and bibid' do
        expect(url).to eq("https://locator-prod.princeton.edu/index.php?loc=#{location}&id=#{properties[:id]}&embed=true")
      end
    end

    describe 'firestone, doc has no call number' do
      let(:location) { 'firestone$stacks' }
      let(:doc_cn) { nil }

      it 'resolves to embeded firestone locator with loc and bibid' do
        expect(url).to eq("https://locator-prod.princeton.edu/index.php?loc=#{location}&id=#{properties[:id]}&embed=true")
      end

      it 'preferred_callno returns nil' do
        expect(url_service.preferred_callno).to be_nil
      end
    end

    describe 'mendel, call number provided' do
      let(:location) { 'mendel$stacks' }
      let(:call_number) { 'Q43.2' }

      it 'resolves to stackmap with provided call number' do
        expect(url).to include('princeton.stackmap')
        expect(url).to include(call_number)
      end
    end

    describe 'mendel, no call number provided' do
      let(:location) { 'mendel$stacks' }

      it 'resolves to stackmap with document call number' do
        expect(url).to include('princeton.stackmap')
        expect(url).to include({ callno: properties[:call_number_browse_s].first }.to_query)
      end
    end

    describe 'no location label' do
      let(:location) { 'annex$UNASSIGNED' }
      let(:call_number) { 'Q43.2' }

      it 'the library is the location label when the holding location has no label' do
        expect(url_service.location_label).to eq('Forrestal Annex')
      end
    end

    describe 'by title location' do
      let(:location) { 'stokes$sprps' }

      it 'uses title as the call number value' do
        expect(url).to include({ callno: properties[:title_display] }.to_query)
      end
      it 'preferred_callno is accessible as a public method' do
        expect(url_service.preferred_callno).to eq(properties[:title_display])
      end
      it 'location label is used instead of library when present' do
        expect(url_service.location_label).to eq('Periodicals. Wallace Hall')
      end
    end
    describe 'by title location with provided call number' do
      let(:location) { 'stokes$sprps' }
      let(:call_number) { 'Q43.2' }

      it 'uses title as the call number value' do
        expect(url).to include({ callno: properties[:title_display] }.to_query)
      end
    end
    describe 'non-stackmap location' do
      let(:location) { 'plasma$res' }

      it 'resolves to branch library page' do
        expect(url).to eq('https://library.princeton.edu/plasma-physics')
      end
    end
  end
  describe '#url with invalid params' do
    describe 'invalid location code' do
      let(:location) { 'not-a-location' }

      it 'resolves to catalog show page url' do
        expect(url).to include("/catalog/#{properties[:id]}")
      end
      it 'returns nil for the location label' do
        expect(url_service.location_label).to be nil
      end
    end
    describe 'nil location' do
      let(:location) { nil }

      it 'resolves to catalog show page url' do
        expect(url).to include("/catalog/#{properties[:id]}")
      end
    end
    describe 'missing doc' do
      let(:location) { 'firestone$stacks' }
      let(:document) { nil }

      it 'resolves to catalog homepage' do
        expect(url).to match(%r{catalog/$})
      end
    end
  end
end
