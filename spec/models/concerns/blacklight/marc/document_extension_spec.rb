# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Blacklight::Marc::DocumentExtension do
  let(:scsb_document) { SolrDocument.new(id: 'SCSB-12345') }
  let(:alma_document) { SolrDocument.new(id: '991234567890') }

  describe '#decompress_marcxml' do
    context 'with valid base64 encoded gzip compressed data' do
      let(:marcxml_content) { '<record><leader>test</leader></record>' }
      let(:compressed_data) do
        sio = StringIO.new
        gz = Zlib::GzipWriter.new(sio)
        gz.write(marcxml_content)
        gz.close
        Base64.strict_encode64(sio.string)
      end
      it 'decompresses the data' do
        decompressed = scsb_document.send(:decompress_marcxml, compressed_data)
        expect(decompressed).to eq(marcxml_content)
      end
    end
    context 'with invalid compressed data' do
      let(:invalid_data) { 'invalid_base64_data' }
      it 'returns the original data and logs an error' do
        # rubocop:disable RSpec/MessageSpies
        expect(Rails.logger).to receive(:error).with(/Failed to decompress MARCXML/)
        # rubocop:enable RSpec/MessageSpies
        result = scsb_document.send(:decompress_marcxml, invalid_data)
        expect(result).to eq(invalid_data)
      end
    end
  end

  describe '#marcxml_record_scsb' do
    let(:valid_marcxml) do
      <<~XML
          <?xml version="1.0"?>
          <record>
          <leader>00000cas  2200445 a 4500</leader>
          <controlfield tag="001">SCSB-8157262</controlfield>
          <controlfield tag="003">CStRLIN</controlfield>
          <controlfield tag="005">19990702102652.2</controlfield>
        </record>
      XML
    end

    context 'with valid MARCXML data' do
      it 'returns a MARC::Record object' do
        sio = StringIO.new
        gz = Zlib::GzipWriter.new(sio)
        gz.write(valid_marcxml)
        gz.close
        compressed_data = Base64.strict_encode64(sio.string)

        result = scsb_document.send(:marcxml_record_scsb, compressed_data)
        expect(result).to be_a(MARC::Record)
        expect(result['001'].value).to eq('SCSB-8157262')
      end
    end

    context 'with nil marcxml_field' do
      it 'returns nil' do
        result = scsb_document.send(:marcxml_record_scsb, nil)
        expect(result).to be_nil
      end
    end
  end
end
