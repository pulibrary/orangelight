# frozen_string_literal: true

require 'marc'
require 'openurl/context_object'

module Blacklight
  module Solr
    module Document
      module Marc
        include Blacklight::Solr::Document::MarcExport
        include OpenURL

        # Prepend our overloaded method to bypass bug in Blacklight
        # See https://stackoverflow.com/questions/5944278/overriding-method-by-another-defined-in-module
        prepend Blacklight::Solr::Document::MarcExportOverride

        class UnsupportedMarcFormatType < RuntimeError; end

        def self.extended(document)
          Blacklight::Solr::Document::MarcExport.register_export_formats(document)
        end

        # Accesses the MARC::Record constructed from data retrieved over the HTTP
        # @return [MARC::Record]
        def to_marc
          @_ruby_marc_obj ||= load_marc
        end

        # These are registered by default
        # @see Blacklight::Solr::Document::MarcExport.register_export_formats

        # Generate the string-serialized XML from the remote MARC record
        # @see Blacklight::Solr::Document::MarcExport#export_as_marcxml
        # @return [String]
        def export_as_marcxml
          return '' unless to_marc
          super
        end

        # @see Blacklight::Solr::Document::MarcExport#export_as_marc
        # @return [String]
        def export_as_marc
          return '' unless to_marc
          super
        end

        # @see Blacklight::Solr::Document::MarcExport#export_as_openurl_ctx_kev
        # @return [String]
        def export_as_openurl_ctx_kev(format = nil)
          ctx = to_ctx(format)
          # send back the encoded string
          ctx.kev
        end

        # Generate the refworks citation format from the remote MARC record
        # @see Blacklight::Solr::Document::MarcExport#export_as_refworks_marc_txt
        # @return [String]
        def export_as_refworks_marc_txt
          return '' unless to_marc
          super
        end

        # These are not registered by default, but still provided as public methods

        # @see Blacklight::Solr::Document::MarcExport#export_as_apa_citation_txt
        # @return [String]
        def export_as_apa_citation_txt
          return '' unless to_marc
          super
        end

        # @see Blacklight::Solr::Document::MarcExport#export_as_mla_citation_txt
        # @return [String]
        def export_as_mla_citation_txt
          return '' unless to_marc
          super
        end

        # @see Blacklight::Solr::Document::MarcExport#export_as_chicago_citation_txt
        # @return [String]
        def export_as_chicago_citation_txt
          return '' unless to_marc
          super
        end

        # @see Blacklight::Solr::Document::MarcExport#export_as_endnote
        # @return [String]
        def export_as_endnote
          return '' unless to_marc
          super
        end

        # return openurl ctx object
        def to_ctx(format)
          @_ctx || build_ctx(format)
        end

        # returns true if doc originated from alma
        def alma_record?
          if /^[0-9]+/.match?(self['id'])
            true
          else
            false
          end
        end

        # does we have any standard numbers that can be used by other services
        def standard_numbers?
          std_numbers.any? { |v| key? v }
        end

        def std_numbers
          %w[lccn_s isbn_s issn_s oclc_s]
        end

        def format_to_openurl_genre(format)
          return 'book' if format == 'book'
          return 'bookitem' if format == 'book'
          return 'journal' if format == 'serial'
          return 'conference' if format == 'conference'
          'unknown'
        end

        # We allow the user to retry in very specific scenarios.
        def can_retry?
          @can_retry
        end

        protected

          def build_ctx(format = nil)
            format ||= first('format')&.downcase
            ctx = ContextObject.new
            id = self['id']
            # title = self['title_citation_display'].first unless self['title_citation_display'].nil?
            date = self['pub_date_display'].first unless self['pub_date_display'].nil?
            author = self['author_citation_display'].first unless self['author_citation_display'].nil?
            corp_author = self['pub_citation_display'].first unless self['pub_citation_display'].nil?
            publisher_info = self['pub_citation_display'].first unless self['pub_citation_display'].nil?
            edition = self['edition_display'].first unless self['edition_display'].nil?
            unless format.nil?
              format = format.is_a?(Array) ? format[0].downcase.strip : format.downcase.strip
              genre = format_to_openurl_genre(format)
            end
            if format == 'book'
              ctx.referent.set_format('book')
              ctx.referent.set_metadata('genre', 'book')
              # ctx.referent.set_metadata('btitle', title)
              # ctx.referent.set_metadata('title', title)
              ctx.referent.set_metadata('au', author)
              ctx.referent.set_metadata('aucorp', corp_author)
              # Place not easilty discernable in solr doc
              # ctx.referent.set_metadata('place', publisher_info)
              ctx.referent.set_metadata('pub', publisher_info)
              ctx.referent.set_metadata('edition', edition)
              ctx.referent.set_metadata('isbn', self['isbn_s'].first) unless self['isbn_s'].nil?
              ctx.referent.set_metadata('date', date)
            elsif /journal/i.match?(format) # checking using include because institutions may use formats like Journal or Journal/Magazine
              ctx.referent.set_format('journal')
              ctx.referent.set_metadata('genre', 'serial')
              # ctx.referent.set_metadata('atitle', title)
              # ctx.referent.set_metadata('title', title)
              # use author display as corp author for journals
              ctx.referent.set_metadata('aucorp', author)
              ctx.referent.set_metadata('issn', self['issn_s'].first) unless self['issn_s'].nil?
            else
              ctx.referent.set_format(genre) # do we need to do this?
              ctx.referent.set_metadata('genre', genre)
              # ctx.referent.set_metadata('title', title)
              ctx.referent.set_metadata('creator', author)
              ctx.referent.set_metadata('aucorp', corp_author)
              # place not discernable in solr doc
              # ctx.referent.set_metadata('place', publisher_info)
              ctx.referent.set_metadata('pub', publisher_info)
              ctx.referent.set_metadata('format', format)
              ctx.referent.set_metadata('issn', self['issn_s'].first) unless self['issn_s'].nil?
              ctx.referent.set_metadata('isbn', self['isbn_s'].first) unless self['isbn_s'].nil?
              ctx.referent.set_metadata('date', date)
            end
            ## common metadata for all formats
            # canonical identifier for the citation?
            ctx.referent.add_identifier("https://bibdata.princeton.edu/bibliographic/#{id}")
            # add pulsearch refererrer
            ctx.referrer.add_identifier('info:sid/catalog.princeton.edu:generator')
            ctx.referent.add_identifier("info:oclcnum/#{self['oclc_s'].first}") unless self['oclc_s'].nil?
            ctx.referent.add_identifier("info:lccn/#{self['lccn_s'].first}") unless self['lccn_s'].nil?
            ctx
          end

          # Retrieves the bib. ID from the Solr Document
          # @return [String]
          def marc_source
            @_marc_source ||= fetch(_marc_source_field)
          end

          # Retrieve the MARC 21 bitstream over the HTTP
          # @return [MARC::Record]
          def marc_record_from_marc21
            return if marc_source.blank?
            MARC::Record.new_from_marc marc_source
          end

          # Retrieve the MARC JSON over the HTTP
          # @return [MARC::Record]
          def marc_record_from_json
            return if marc_source.blank?

            begin
              marc_json = JSON.parse(marc_source)
            rescue JSON::ParserError => json_error
              Rails.logger.error "#{self.class}: Failed to parse the MARC JSON: #{json_error}"
              return
            end
            MARC::Record.new_from_hash marc_json
          end

          # Construct a MARC::Record using MARC record data retrieved over the HTTP
          # @return [MARC::Record]
          def load_marc
            marc_format = _marc_format_type.to_s

            case marc_format
            when 'marcxml'
              marc_record_from_marcxml
            when 'marc21'
              marc_record_from_marc21
            when 'json'
              marc_record_from_json
            else
              raise UnsupportedMarcFormatType, "Only marcxml, marc21, and json are supported, this documents format is #{_marc_format_type} and the current extension parameters are #{self.class.extension_parameters.inspect}"
            end
          rescue StandardError => e
            Rails.logger.error("Blacklight failed to parse MARC record. Exception was: #{e}")
            nil
          end

          # Construct a MARC::Record using MARC-XML data retrieved over the HTTP
          # @return [MARC::Record]
          def marc_record_from_marcxml
            id = fetch(_marc_source_field)

            response = Faraday.get("#{Requests.config['bibdata_base']}/bibliographic/#{id}")
            @can_retry = response.status == 429
            response_stream = StringIO.new(response.body)
            marc_reader = MARC::XMLReader.new(response_stream)
            marc_records = marc_reader.to_a
            marc_records.first
          end

          def _marc_helper
            @_marc_helper ||= Blacklight::Marc::Document.new fetch(_marc_source_field), _marc_format_type
          end

          def _marc_source_field
            self.class.extension_parameters[:marc_source_field]
          end

          def _marc_format_type
            # TODO: Raise if not present
            self.class.extension_parameters[:marc_format_type]
          end

          # Overwites the get_author_list(record) method from the module Blacklight::Solr::Document::MarcExport
          def get_author_list(record)
            author_list = []
            authors_primary = record.find { |f| f.tag == '100' }
            begin
              author_primary = authors_primary.find { |s| s.code == 'a' }.value unless authors_primary.nil?
            rescue StandardError
              ''
            end
            author_list.push(clean_end_punctuation(author_primary)) unless author_primary.nil?
            authors_secondary = record.find_all { |f| f.tag == '700' }
            authors_secondary&.each do |l|
              unless l.find { |s| s.code == 'a' }.nil?
                author_list.push(clean_end_punctuation(l.find { |s| s.code == 'a' }.value)) unless l.find { |s| s.code == 'a' }.value.nil?
              end
            end
            author_list.uniq!
            author_list
          end
      end
    end
  end
end
