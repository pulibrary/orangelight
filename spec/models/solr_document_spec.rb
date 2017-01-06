require 'rails_helper'

RSpec.describe SolrDocument do
  subject { described_class.new(properties) }
  let(:properties) { {} }

  describe '#identifiers' do
    context 'with no identifiers' do
      it 'is a blank array' do
        expect(subject.identifiers).to eq []
      end
    end
    context 'with identifiers' do
      let(:properties) do
        {
          'lccn_s' => ['2001522653'],
          'isbn_s' => ['9781400827824'],
          'oclc_s' => %w(19590730 301985443)
        }
      end
      it 'has an identifier object each' do
        expect(subject.identifiers.length).to eq 4
      end
    end
  end

  describe '#identifier_data' do
    context 'with identifiers' do
      let(:properties) do
        {
          'lccn_s' => ['2001522653'],
          'isbn_s' => ['9781400827824'],
          'oclc_s' => %w(19590730 301985443)
        }
      end
      it 'returns a hash of identifiers for data embeds' do
        expect(subject.identifier_data).to eq(
          lccn: [
            '2001522653'
          ],
          isbn: [
            '9781400827824'
          ],
          oclc: %w(
            19590730
            301985443)
        )
      end
    end
  end

  describe '#export_as_openurl_ctx_kev' do
    let(:properties) do
      {
        'id' => '123',
        'format' => ['Book']
      }
    end
    let(:format_string) { 'info:ofi/fmt:kev:mtx:book' }

    it 'returns an encoded string' do
      expect((subject.export_as_openurl_ctx_kev('book').is_a? String)).to be true
      expect(subject.export_as_openurl_ctx_kev('book')).to include("rft_val_fmt=#{CGI.escape(format_string)}")
    end
  end

  describe '#to_ctx' do
    context 'A book' do
      let(:properties) do
        {
          'id' => '123',
          'format' => ['Book'],
          'title_citation_display' => ['citation title']
        }
      end

      it 'returns a ctx with a format book' do
        expect(subject.to_ctx(subject['format']).to_hash['rft.genre']).to eq('book')
      end

      it 'Has a rft.title param' do
        expect(subject.to_ctx(subject['format']).to_hash['rft.title']).to eq(subject['title_citation_display'].first)
      end
    end

    context 'A Journal' do
      let(:properties) do
        {
          'id' => '123',
          'format' => ['Journal'],
          'title_citation_display' => ['A journal title']
        }
      end

      it 'returns a ctx with a format serial' do
        expect(subject.to_ctx(subject['format']).to_hash['rft.genre']).to eq('serial')
      end

      it 'has a journal rft.atitle param' do
        expect(subject.to_ctx(subject['format']).to_hash['rft.atitle']).to eq(subject['title_citation_display'].first)
      end
    end

    context 'Other formats' do
      let(:properties) do
        {
          'id' => '123',
          'format' => ['Musical score']
        }
      end

      it 'returns a ctx with format unknown' do
        expect(subject.to_ctx(subject['format']).to_hash['rft.genre']).to eq('unknown')
      end
    end
  end

  describe '#standard_numbers?' do
    context 'With standard numbers' do
      let(:properties) do
        {
          'id' => '1213313',
          'lccn_s' => ['2001522653'],
          'isbn_s' => ['9781400827824'],
          'oclc_s' => %w(19590730 301985443)
        }
      end

      it 'returns true when one or more standard number keys are present' do
        expect(subject.standard_numbers?).to be true
      end
    end

    context 'Without standard numbers' do
      let(:properties) do
        {
          'id' => '1213313'
        }
      end

      it 'returns false when no standard number keys are present' do
        expect(subject.standard_numbers?).to be false
      end
    end
  end

  describe 'voyager_record?' do
    context 'A voyager record' do
      let(:properties) do
        {
          'id' => '1213313'
        }
      end

      it 'returns true with a voyager record' do
        expect(subject.voyager_record?).to be true
      end
    end

    context 'A non-voyager record' do
      let(:properties) do
        {
          'id' => 'dsp1213313'
        }
      end

      it 'returns false when it did not originate from voyager' do
        expect(subject.voyager_record?).to be false
      end
    end
  end
end
