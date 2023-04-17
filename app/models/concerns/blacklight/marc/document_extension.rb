# frozen_string_literal: true

require 'marc'
require 'openurl/context_object'

# rubocop:disable Metrics/ModuleLength
module Blacklight
  module Marc
    module DocumentExtension
      include Blacklight::Marc::DocumentExport
      include OpenURL

      # Prepend our overloaded method to bypass bug in Blacklight
      # See https://stackoverflow.com/questions/5944278/overriding-method-by-another-defined-in-module
      prepend Blacklight::MARC::Document::MarcExportOverride

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

      # We allow the user to retry in very specific scenarios.
      def can_retry?
        @can_retry
      end

        protected

          def build_ctx(format = nil)
            format ||= first('format')&.downcase
            unless format.nil?
              format = format.is_a?(Array) ? format[0].downcase.strip : format.downcase.strip
            end
            if format == 'book'
              BookCtxBuilder.new(document: self, format:).build
            elsif /journal/i.match?(format) # checking using include because institutions may use formats like Journal or Journal/Magazine
              JournalCtxBuilder.new(document: self, format:).build
            else
              CtxBuilder.new(document: self, format:).build
            end
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
            marc_reader = ::MARC::XMLReader.new(response_stream)
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
    # rubocop:enable Metrics/ModuleLength
  end
end
