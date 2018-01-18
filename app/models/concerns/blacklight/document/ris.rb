# frozen_string_literal: false

require 'builder'
# This module provide Dublin Core export based on the document's semantic values
module Blacklight
  module Document
    module Ris
      def self.extended(document)
        # Register our exportable formats
        Blacklight::Document::Ris.register_export_formats(document)
      end

      def self.register_export_formats(document)
        document.will_export_as(:ris, 'application/x-research-info-systems')
        document.will_export_as(:mendeley, 'application/x-research-info-systems')
      end

      def ris_field_names
        {
          title_display: 'TI',
          advisor_display: 'A2',
          department_display: 'A2',
          title_vern_display: 'T2',
          description_display: 'N2',
          summary_note_display: 'N2',
          series_display: 'T3',
          edition_display: 'VL',
          pub_date_display: 'PY',
          pub_citation_display: 'PB',
          isbn_s: 'SN',
          issn_s: 'SN',
          language_facet: 'LA',
          electronic_access_1display: 'UR',
          subject_facet: 'KW'
        }
      end

      def export_as_ris
        indexed_urls
        ris = "TY - #{ris_format}\n"
        ris += ris_authors
        each do |field, values|
          Array.wrap(values).each do |v|
            ris += "#{ris_field_name?(field)} - #{v}\n" if ris_field_name?(field)
          end
        end
        ris += 'ER - '
        ris
      end

      alias export_as_mendeley export_as_ris
      alias export_as_zoterio export_as_ris

      private

        def ris_format
          ris_format_mapping[self[:format].first]
        end

        def ris_format_mapping
          {
            'Audio' => 'SOUND',
            'Book' => 'BOOK',
            'Data file' => 'DATA',
            'Journal' => 'JFULL',
            'Manuscript' => 'MANSCPT',
            'Map' => 'MAP',
            'Musical Score' => 'MUSIC',
            'Musical score' => 'MUSIC',
            'Senior Thesis' => 'GEN',
            'Senior thesis' => 'GEN',
            'Video/Projected medium' => 'ADVS',
            'Visual material' => 'ART'
          }
        end

        def ris_field_name?(field)
          ris_field_names[field.to_sym]
        end

        def ris_authors
          authors = ''
          if self[:author_roles_1display].nil?
            unless self[:author_display].nil?
              Array.wrap(self[:author_display]).each do |v|
                authors += "AU - #{v}\n"
              end
            end
          else
            author_values = JSON.parse(self[:author_roles_1display]).symbolize_keys
            author_values.each do |key, value|
              if key == :primary_author # is key always a string rather than array?
                authors += "AU - #{value}\n"
              else
                unless key.empty?
                  Array.wrap(value).each do |v|
                    authors += "A2 - #{v}\n"
                  end
                end
              end
            end
          end
          authors
        end

        def indexed_urls
          unless self[:electronic_access_1display].nil?
            url_values = JSON.parse(self[:electronic_access_1display]).keys
            self[:electronic_access_1display] = url_values
          end
        end
    end
  end
end
