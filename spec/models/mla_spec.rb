# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::Document::Mla, citation: true do
  let(:document) { SolrDocument.new(properties).export_as_mla }

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
        expect(document).to include('Saer')
        expect(document).to include('Juan José. ')
      end

      it 'includes the author with the proper delimiter', skip: "Fixing the bug with CiteProc" do
        expect(document).to include('Saer, Juan José. ')
      end

      it 'includes the title in italics' do
        expect(document).to include('<i>El Entenado</i>')
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
        expect(document).to include('1A edición'.downcase)
      end
    end
  end
end
