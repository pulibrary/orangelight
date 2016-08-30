require 'marc'

module Blacklight
  module Solr
    module Document
      module Marc
        include Blacklight::Solr::Document::MarcExport

        class UnsupportedMarcFormatType < RuntimeError; end

        def self.extended(document)
          Blacklight::Solr::Document::MarcExport.register_export_formats(document)
        end

        # ruby-marc object
        def to_marc
          @_ruby_marc_obj ||= load_marc
        end

        # returns true if Marc record is fetchable from bibdata
        def voyager_record?
          !to_marc.nil?
        end

        def export_as_openurl_ctx_kev(format = nil)
          title = to_marc.find { |field| field.tag == '245' }
          author = to_marc.find { |field| field.tag == '100' }
          corp_author = to_marc.find { |field| field.tag == '110' }
          publisher_info = to_marc.find { |field| field.tag == '260' }
          edition = to_marc.find { |field| field.tag == '250' }
          isbn = to_marc.find { |field| field.tag == '020' }
          issn = to_marc.find { |field| field.tag == '022' }
          id = to_marc.find { |field| field.tag == '001' }
          unless format.nil?
            format = format.is_a?(Array) ? format[0].downcase.strip : format.downcase.strip
            genre = format_to_openurl_genre(format)
          end
          export_text = ''
          if format == 'book'
            export_text << 'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rfr_id=info%3Asid%2Fpulsearch.princeton.edu%3Agenerator&amp;rft.genre=book&amp;'
            export_text << "rft.btitle=#{(title.nil? || title['a'].nil?) ? '' : CGI.escape(title['a'])}+#{(title.nil? || title['b'].nil?) ? '' : CGI.escape(title['b'])}&amp;"
            export_text << "rft.title=#{(title.nil? || title['a'].nil?) ? '' : CGI.escape(title['a'])}+#{(title.nil? || title['b'].nil?) ? '' : CGI.escape(title['b'])}&amp;"
            export_text << "rft.au=#{(author.nil? || author['a'].nil?) ? '' : CGI.escape(author['a'])}&amp;"
            export_text << "rft.aucorp=#{CGI.escape(corp_author['a']) if corp_author['a']}+#{CGI.escape(corp_author['b']) if corp_author['b']}&amp;" unless corp_author.blank?
            export_text << "rft.date=#{(publisher_info.nil? || publisher_info['c'].nil?) ? '' : CGI.escape(publisher_info['c'])}&amp;"
            export_text << "rft.place=#{(publisher_info.nil? || publisher_info['a'].nil?) ? '' : CGI.escape(publisher_info['a'])}&amp;"
            export_text << "rft.pub=#{(publisher_info.nil? || publisher_info['b'].nil?) ? '' : CGI.escape(publisher_info['b'])}&amp;"
            export_text << "rft.edition=#{(edition.nil? || edition['a'].nil?) ? '' : CGI.escape(edition['a'])}&amp;"
            export_text << "rft.isbn=#{(isbn.nil? || isbn['a'].nil?) ? '' : isbn['a']}"
            export_text << '&amp;rft.genre=book'
          elsif format =~ /journal/i # checking using include because institutions may use formats like Journal or Journal/Magazine
            export_text << 'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=article&amp;'
            export_text << "rft.title=#{(title.nil? || title['a'].nil?) ? '' : CGI.escape(title['a'])}+#{(title.nil? || title['b'].nil?) ? '' : CGI.escape(title['b'])}&amp;"
            export_text << "rft.atitle=#{(title.nil? || title['a'].nil?) ? '' : CGI.escape(title['a'])}+#{(title.nil? || title['b'].nil?) ? '' : CGI.escape(title['b'])}&amp;"
            export_text << "rft.aucorp=#{CGI.escape(corp_author['a']) if corp_author['a']}+#{CGI.escape(corp_author['b']) if corp_author['b']}&amp;" unless corp_author.blank?
            export_text << "rft.date=#{(publisher_info.nil? || publisher_info['c'].nil?) ? '' : CGI.escape(publisher_info['c'])}&amp;"
            export_text << "rft.issn=#{(issn.nil? || issn['a'].nil?) ? '' : issn['a']}"
            export_text << '&amp;rft.genre=serial'
          else
            export_text << 'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;'
            export_text << 'rft.title=' + ((title.nil? || title['a'].nil?) ? '' : CGI.escape(title['a']))
            export_text << ((title.nil? || title['b'].nil?) ? '' : CGI.escape(' ') + CGI.escape(title['b']))
            export_text << '&amp;rft.creator=' + ((author.nil? || author['a'].nil?) ? '' : CGI.escape(author['a']))
            export_text << "&amp;rft.aucorp=#{CGI.escape(corp_author['a']) if corp_author['a']}+#{CGI.escape(corp_author['b']) if corp_author['b']}" unless corp_author.blank?
            export_text << '&amp;rft.date=' + ((publisher_info.nil? || publisher_info['c'].nil?) ? '' : CGI.escape(publisher_info['c']))
            export_text << '&amp;rft.place=' + ((publisher_info.nil? || publisher_info['a'].nil?) ? '' : CGI.escape(publisher_info['a']))
            export_text << '&amp;rft.pub=' + ((publisher_info.nil? || publisher_info['b'].nil?) ? '' : CGI.escape(publisher_info['b']))
            export_text << '&amp;rft.format=' + (format.nil? ? '' : CGI.escape(format))
            export_text << "&amp;rft.genre=#{genre}"
            unless issn.nil?
              export_text << "&amp;rft.issn=#{(issn.nil? || issn['a'].nil?) ? '' : issn['a']}"
            end
            unless isbn.nil?
              export_text << "&amp;rft.isbn=#{(isbn.nil? || isbn['a'].nil?) ? '' : isbn['a']}"
            end
          end

          export_text << '&amp;rft_id=' + (id.nil? ? '' : CGI.escape("http://bibdata.princeton.edu/bibliographic/#{id.value}"))
          unless self['oclc_s'].nil?
            export_text << '&amp;rft_id=' + CGI.escape("info:oclcnum/#{self['oclc_s'][0]}")
          end
          unless self['lccn_s'].nil?
            export_text << '&amp;rft_id=' + CGI.escape("info:lccn/#{self['lccn_s'][0]}")
          end
          export_text.html_safe unless export_text.blank?
        end

        def format_to_openurl_genre(format)
          return 'book' if format == 'book'
          return 'bookitem' if format == 'book'
          return 'journal' if format == 'serial'
          return 'conference' if format == 'conference'
          'unknown'
        end

        protected

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
