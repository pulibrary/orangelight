# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::Document::Ris do
  subject { SolrDocument.new(properties).export_as_ris }

  context 'For a standard MARC Record' do
    describe '#export_as_ris' do
      let(:properties) do
        {
          'id' => '9618072',
          'author_roles_1display' => %({"secondary_authors":[],"translators":[],"editors":[],"compilers":[],"primary_author":"Kim, Mu-bong"}),
          'title_citation_display' => ["Yŏkchu Pulsŏl Amit'agyŏng ŏnhae ; Yŏkchu Pulchŏngsim taranigyŏng ŏnhae /", '역주 불설 아미타경 언해 ; 역주 불정심 다라니경 언해 /'],
          'title_vern_display' => '역주불설아미타경언해불정심다라니경언해',
          'compiled_created_t' => [
            "Yŏkchu pulsŏl amit'agyŏng ŏnhae pulchŏng simdaranigyŏng ŏnhae.",
            '역주불설아미타경언해불정심다라니경언해'
          ],
          'pub_created_display' => [
            'Sŏul: Sejong Taewang Kinyŏm Saŏphoe, 2018.',
            '서울: (사)세종대왕기념사업회, 2018.'
          ],
          'pub_created_s' => [
            'Sŏul: Sejong Taewang Kinyŏm Saŏphoe, 2018.',
            '서울: (사)세종대왕기념사업회, 2018.'
          ],
          'pub_citation_display' => [
            'Sŏul: Sejong Taewang Kinyŏm Saŏphoe',
            '서울: (사)세종대왕기념사업회'
          ],
          'pub_date_display' => [
            '2018'
          ],
          'pub_date_start_sort' => 2018,
          'format' => [
            'Book'
          ],
          'description_t' => [
            '295 p.'
          ],
          'language_facet' => [
            'Korean'
          ],
          'language_code_s' => [
            'kor'
          ],
          'isbn_display' => [
            '9788982757365'
          ],
          'isbn_s' => [
            '9788982757365'
          ],
          "call_number_display": [
            'BQ2043.K6 T757 2008'
          ],
          "form_genre_display": [
            'Commentaries.'
          ],
          "notes_display": [
            'Includes photocopy of original text, with pages numbered in opposite direction.',
            'Translation and commentaries of: Tripiṭaka. Sūtrapiṭaka. Sukhāvatīvyūha (Smaller) and Dharanī.'
          ]
        }
      end

      it 'Starts with a valid RIS Format' do
        expect(subject).to match(/^TY - BOOK/)
      end

      it 'Contains valid author information' do
        expect(subject).to match(/AU - \w+/)
      end

      it 'Contains title citation information' do
        expect(subject).to match(/TI - Yŏkchu Pulsŏl Amit'agyŏng ŏnhae ; Yŏkchu Pulchŏngsim taranigyŏng ŏnhae /)
      end

      it 'Contains vernacular title as a secondary title' do
        expect(subject).to match(/T2 - 역주불설아미타경언해불정심다라니경언해/)
      end

      it 'Contains an end of record character' do
        expect(subject).to match(/\nER - $/)
      end

      it 'Contains call number information' do
        expect(subject).to match(/CN - BQ2043.K6 T757 2008/)
      end

      it 'Contains form genre' do
        expect(subject).to match(/M3 - Commentaries/)
      end

      it 'Contains notes' do
        expect(subject).to match(/N1 - Includes photocopy of original text, with pages numbered in opposite direction./)
      end
    end
  end

  context 'For a Senior Thesis Record' do
    describe '#export_as_ris' do
      let(:properties) do
        {
          'title_display' => 'A Senior Thesis',
          'electronic_access_1display' => %({"http://arks.princeton.edu/ark:/88435/dsp01bn999692c":["DataSpace","Full text"]}),
          'author_display' => [
            'Doe, Jane'
          ],
          'advisor_display' => [
            'Smith, Joe'
          ],
          'department_display' => [
            'Princeton University. Department of Computer Science'
          ],
          'format' => [
            'Senior thesis'
          ]
        }
      end

      it 'is listed as a GEN RIS format' do
        expect(subject).to match(/^TY - GEN/)
      end

      it 'Contains an ARK' do
        expect(subject).to match(%r{UR - http://arks.princeton.edu/ark:/88435/dsp01bn999692c})
      end

      it 'Has a first Author' do
        expect(subject).to match(/AU - Doe, Jane/)
      end

      it 'lists the department as a second author' do
        expect(subject).to match(/A2 - Princeton University. Department of Computer Science/)
      end

      it 'lists the advisor as a second author' do
        expect(subject).to match(/A2 - Smith, Joe/)
      end
    end
  end
end
