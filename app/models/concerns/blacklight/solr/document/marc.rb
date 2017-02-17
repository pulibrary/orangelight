require 'marc'
require 'openurl/context_object'

module Blacklight
  module Solr
    module Document
      module Marc
        include Blacklight::Solr::Document::MarcExport
        include OpenURL

        class UnsupportedMarcFormatType < RuntimeError; end

        def self.extended(document)
          Blacklight::Solr::Document::MarcExport.register_export_formats(document)
        end

        # ruby-marc object
        def to_marc
          @_ruby_marc_obj ||= load_marc
        end

        # return openurl ctx object
        def to_ctx(format)
          @_ctx || build_ctx(format)
        end

        # returns true if doc originated from voyager
        def voyager_record?
          if self['id'] =~ /^[0-9]+/
            true
          else
            false
          end
        end

        def umlaut_fulltext_eligible?
          if (umlaut_full_text_formats & self['format'].map!(&:downcase)).empty?
            false
          else
            true
          end
        end

        def umlaut_full_text_formats
          %w(book journal)
        end

        # does we have any standard numbers that can be used by other services
        def standard_numbers?
          std_numbers.any? { |v| key? v }
        end

        def std_numbers
          %w(lccn_s isbn_s issn_s oclc_s)
        end

        def export_as_openurl_ctx_kev(format = nil)
          ctx = to_ctx(format)
          # send back the encoded string
          ctx.kev
        end

        def format_to_openurl_genre(format)
          return 'book' if format == 'book'
          return 'bookitem' if format == 'book'
          return 'journal' if format == 'serial'
          return 'conference' if format == 'conference'
          'unknown'
        end

        protected

          def build_ctx(format = nil)
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
            elsif format =~ /journal/i # checking using include because institutions may use formats like Journal or Journal/Magazine
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
            end
            ## common metadata for all formats
            ctx.referent.set_metadata('date', date)
            # canonical identifier for the citation?
            ctx.referent.add_identifier("https://bibdata.princeton.edu/bibliographic/#{id}")
            # add pulsearch refererrer
            ctx.referrer.add_identifier('info:sid/pulsearch.princeton.edu:generator')
            ctx.referent.add_identifier("info:oclcnum/#{self['oclc_s'].first}") unless self['oclc_s'].nil?
            ctx.referent.add_identifier("info:lccn/#{self['lccn_s'].first}") unless self['lccn_s'].nil?
            ctx
          end

          def marc_source
            @_marc_source ||= fetch(_marc_source_field)
          end

          def load_marc
            case _marc_format_type.to_s
            when 'marcxml'
              marc_record_from_marcxml
            when 'marc21'
              return MARC::Record.new_from_marc(fetch(_marc_source_field))
            when 'json'
              return MARC::Record.new_from_hash(JSON.parse(fetch(_marc_source_field)))
            else
              raise UnsupportedMarcFormatType.new("Only marcxml, marc21, and json are supported, this documents format is #{_marc_format_type} and the current extension parameters are #{self.class.extension_parameters.inspect}")
            end
          rescue StandardError => e
            Rails.logger.error("Blacklight failed to parse MARC record. Exception was: #{e}")
          end

          def marc_record_from_marcxml
            id = fetch(_marc_source_field)
            record = Faraday.get("#{ENV['bibdata_base']}/bibliographic/#{id}").body
            MARC::XMLReader.new(StringIO.new(record)).to_a.first
          end

          def _marc_helper
            @_marc_helper ||= (
              Blacklight::Marc::Document.new fetch(_marc_source_field), _marc_format_type)
          end

          def _marc_source_field
            self.class.extension_parameters[:marc_source_field]
          end

          def _marc_format_type
            # TODO: Raise if not present
            self.class.extension_parameters[:marc_format_type]
          end
      end
    end
  end
end
