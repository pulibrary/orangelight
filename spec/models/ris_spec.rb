# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blacklight::Document::Ris do
  subject(:document) { SolrDocument.new(properties).export_as_ris }

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
        expect(document).to match(/^TY - BOOK/)
      end

      it 'Contains valid author information' do
        expect(document).to match(/AU - \w+/)
      end

      it 'Contains title citation information' do
        expect(document).to match(/TI - Yŏkchu Pulsŏl Amit'agyŏng ŏnhae ; Yŏkchu Pulchŏngsim taranigyŏng ŏnhae /)
      end

      it 'Contains vernacular title as a secondary title' do
        expect(document).to match(/T2 - 역주불설아미타경언해불정심다라니경언해/)
      end

      it 'Contains an end of record character' do
        expect(document).to match(/\nER - $/)
      end

      it 'Contains call number information' do
        expect(document).to match(/CN - BQ2043.K6 T757 2008/)
      end

      it 'Contains form genre' do
        expect(document).to match(/M3 - Commentaries/)
      end

      it 'Contains notes' do
        expect(document).to match(/N1 - Includes photocopy of original text, with pages numbered in opposite direction./)
      end
    end
  end

  context 'For a SCSB record with a marcxml field' do
    describe '#export_as_ris' do
      let(:properties) do
        {
          "id": "SCSB-11759184",
          "marcxml": "H4sIAMhEaGkAA71W3U7bMBh9Fd8ZJEj8EycOSyOxMg0k9iNgQtqdk5jWw42rJB0w7XKPt4faF0pRVYIpXKyRGis59nfOiX3srNGlayp0O7N1O8LTrpsfhOHNzU1gXRlM3M/w0+HZmNGwtWaG88xqVekmJySKZK1mSDFGCBXJyQJFgpAsfABkpau7xtkro22FOjUZYcDh/Hx8/n6f0kSkVEZZuI4a7iNwDhUYieFKOSdpkGzTTeI85UQw0tI0kQh+kwap/o6K/o8Q8pvAM+2qbYZLYbiUEBgxTtMI6PA0opsdK9WpZS9TV3SEEe4b7L6xHIeDmqxdFEtU6So9wgrnO1/G7nS8yySNQarIwhXkCfjXI5iCRi6pIHQdHj5y8NCJVnQEGaTz+SgmPLhImIdIgfOLhKPe3NttCZAVAfJAgEXDfly0qnGLcqr//mmDV8tbuc3iYXmHXT9wrdCBX9+H68q1gETf7yau3fOAS5z3RrydKifDVCmL0Tx4iaiyFhlrA/TOz5FRVM7eTlKQaJDkSV3aRaVbVJjCGjdp1HxqSmVRo690o+sSXu2ACsrIPgja3ZoB3Zwv8TM2rc+XPfTRqLrum6+us1Ka/Kc6QvLBOqWbzUzXaYgfBy52ytQvfFlCJQQC9aAqnJsazXUz193CdHce6BXOz/T48Cs6n6oGSIydtbrsjPOxgJV8/O3UA4BEZozKWLBUSsjShwh9ZXSsrJOCPbUOnDg+8lCYbpdt5pls24CRfn2KJIn4C0HZlm0xtW9edzKJn0rdrngfIZKLlEe+qfEDMvGnMlYVVntg1zi/PPHZO8c5Z3AwIGkKOzzsZR7sLRwF7meXf7M7vvS8t5ufe93WcHmwyf8BR3HfFuEIAAA=",
          "numeric_id_b": false,
          "other_id_s": [
            "990030569940203941"
          ],
          "author_citation_display": [
            "Tsarouchēs, Giannēs"
          ],
          "author_roles_1display": "{\"secondary_authors\":[\"Tsarouchēs, Giannēs\"],\"translators\":[],\"editors\":[],\"compilers\":[]}",
          "author_s": [
            "Tsarouchēs, Giannēs"
          ],
          "title_display": "Tsarouchēs.",
          "title_t": [
            "Tsarouchēs."
          ],
          "title_citation_display": [
            "Tsarouchēs"
          ],
          "compiled_created_t": [
            "Tsarouchēs."
          ],
          "pub_created_display": [
            "Athēna : Ekdosē Zygos, 1978."
          ],
          "pub_created_s": [
            "Athēna : Ekdosē Zygos, 1978."
          ],
          "pub_citation_display": [
            "Athēna: Ekdosē Zygos"
          ],
          "publication_location_citation_display": [
            "Athēna"
          ],
          "publisher_citation_display": [
            "Ekdosē Zygos"
          ],
          "pub_date_display": [
            "1978"
          ],
          "pub_date_start_sort": 1978,
          "publication_date_citation_display": [
            "1978"
          ],
          "format": [
            "Book"
          ],
          "description_display": [
            "126 p. : all ill. ; 21 cm."
          ],
          "description_t": [
            "126 p. : all ill. ; 21 cm."
          ],
          "number_of_pages_citation_display": [
            "126 p."
          ],
          "bib_ref_notes_display": [
            "Includes bibliographical references (p. 120-126)."
          ],
          "language_name_display": [
            "Greek, Modern (1453-)"
          ],
          "language_facet": [
            "Greek, Modern (1453- )"
          ],
          "language_iana_s": [
            "el"
          ],
          "mult_languages_iana_s": [
            "el"
          ],
          "action_notes_1display": "[{\"description\":\"Committed to retain in perpetuity — ReCAP Shared Collection (HUL)\",\"uri\":\"\"}]",
          "lc_subject_display": [
            "Tsarouchēs, Giannēs"
          ],
          "subject_facet": [
            "Tsarouchēs, Giannēs"
          ],
          "lc_subject_facet": [
            "Tsarouchēs, Giannēs"
          ],
          "related_name_json_1display": "{\"Related name\":[\"Tsarouchēs, Giannēs\"]}",
          "oclc_s": [
            "28160025"
          ],
          "other_version_s": [
            "ocm28160025"
          ],
          "holdings_1display": "{\"12577432\":{\"location_code\":\"scsbhl\",\"location\":\"Remote Storage\",\"library\":\"ReCAP\",\"call_number\":\"ND603.T72 T73 1978x\",\"call_number_browse\":\"ND603.T72 T73 1978x\",\"items\":[{\"holding_id\":\"12577432\",\"id\":\"18359341\",\"status_at_load\":\"Available\",\"barcode\":\"32044099117160\",\"storage_location\":\"HD\",\"cgd\":\"Shared\",\"collection_code\":\"HW\"}]}}",
          "recap_notes_display": [
            "H - S"
          ],
          "location_code_s": [
            "scsbhl"
          ],
          "location": [
            "ReCAP"
          ],
          "location_display": [
            "Remote Storage"
          ],
          "advanced_location_s": [
            "scsbhl",
            "ReCAP"
          ],
          "call_number_display": [
            "ND603.T72 T73 1978x"
          ],
          "call_number_browse_s": [
            "ND603.T72 T73 1978x"
          ]
        }
      end
      it 'Starts with a valid RIS Format' do
        expect(document).to match(/^TY - BOOK/)
      end
      it 'Contains valid secondary author information' do
        expect(document).to match(/A2 - Tsarouchēs, Giannēs/)
      end
      it 'Contains title citation information' do
        expect(document).to match(/TI - Tsarouchēs/)
      end
      it 'Contains an end of record character' do
        expect(document).to match(/\nER - $/)
      end
      it 'Contains subject information' do
        expect(document).to match(/KW - Tsarouchēs, Giannēs/)
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
        expect(document).to match(/^TY - GEN/)
      end

      it 'Contains an ARK' do
        expect(document).to include 'UR - http://arks.princeton.edu/ark:/88435/dsp01bn999692c'
      end

      it 'Has a first Author' do
        expect(document).to match(/AU - Doe, Jane/)
      end

      it 'lists the department as a second author' do
        expect(document).to match(/A2 - Princeton University. Department of Computer Science/)
      end

      it 'lists the advisor as a second author' do
        expect(document).to match(/A2 - Smith, Joe/)
      end
    end
  end

  context 'For a work with a URL' do
    let(:properties) do
      {
        "id": "9945502073506421",
        "author_roles_1display":
          "{\"secondary_authors\":[\"Stets, Jan E.\"],\"translators\":[],\"editors\":[],\"compilers\":[],\"primary_author\":\"Turner, Jonathan H.\"}",
        "format": [
          "Book"
        ],
        "title_citation_display": [
          "The sociology of emotions"
        ],
        "electronic_access_1display":
        "{\"http://www.loc.gov/catdir/description/cam051/2004018645.html\":[\"Publisher description\"],\"http://www.loc.gov/catdir/toc/ecip0421/2004018645.html\":[\"Table of contents\"]}"
      }
    end
    it "handles authors in the author_roles_1display field" do
      expect(document).to match(/AU - Turner, Jonathan H./)
      expect(document).to match(/A2 - Stets, Jan E./)
    end
    it "has a proper url in the UR field" do
      expect(document).to match(/UR - http/)
    end
  end
end
