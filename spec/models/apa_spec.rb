# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::Document::Apa, citation: true do
  let(:solr_document) { SolrDocument.new(properties) }
  let(:document) { solr_document.export_as_apa }

  before do
    allow(SolrDocument).to receive(:new).and_return(solr_document)
    allow(solr_document).to receive(:citation_fields_from_solr).and_return(properties)
  end
  context 'with a SCSB record' do
    context 'with a book' do
      let(:properties) do
        {
          id: "SCSB-2635660",
          format: ['Book'],
          author_citation_display: ["Saer, Juan José"],
          edition_display: ['1a edición.'],
          title_citation_display: ['El entenado'],
          pub_citation_display: ["Barcelona: Destino"],
          pub_date_start_sort: 1988
        }
      end

      it 'includes the author' do
        expect(document).to include('Saer, J. J.')
      end

      it 'includes the author with the proper delimiter' do
        expect(document).to include('Saer, J. J. ')
      end

      it 'includes the title in italics' do
        expect(document).to include('<i>El entenado</i>')
      end

      it 'includes the publisher' do
        expect(document).to include('Destino')
      end

      it 'does not include the place of publication' do
        expect(document).not_to include('Barcelona')
      end

      it 'includes the publication date' do
        expect(document).to include('1988')
      end

      it 'includes the edition' do
        expect(document).to include('(1a edición)')
      end
    end
    context 'with no author' do
      let(:properties) do
        {
          id: "SCSB-2635660",
          format: ['Book'],
          edition_display: ['1a edición.'],
          title_citation_display: ['El entenado'],
          pub_citation_display: ["Barcelona: Destino"],
          pub_date_start_sort: 1988
        }
      end

      it 'does not raise an error' do
        expect { document }.not_to raise_error
      end
    end
  end
end
