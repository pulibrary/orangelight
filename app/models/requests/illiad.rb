# frozen_string_literal: true
module Requests
  # ILL related helpers
  class Illiad
    attr_reader :enum, :chron, :call_number

    METADATA_MAPPING = {
      "genre" => "genre", "issn" => "issn", "isbn" => "isbn", "stitle" => "stitle", "date" => "rft.date", "atitle" => "atitle",
      "pub" => "rft.pub", "place" => "rft.place", "edition" => "rft.edition"
    }.freeze
    private_constant :METADATA_MAPPING

    def initialize(enum: nil, chron: nil, call_number: nil)
      @enum = enum
      @chron = chron
      @call_number = call_number
    end

    # accepts a @solr_open_url_context object and formats it appropriately for ILL
    def illiad_request_url(solr_open_url_context, note: nil)
      query_params = illiad_query_parameters(referrer: solr_open_url_context.referrer, referent: solr_open_url_context.referent,
                                             metadata: solr_open_url_context.referent.metadata, note:)
      "#{Requests::Config[:ill_base]}?#{query_params}"
    end

    def illiad_request_parameters(solr_open_url_context, note: nil)
      mapping = map_metdata(referrer: solr_open_url_context.referrer, referent: solr_open_url_context.referent,
                            metadata: solr_open_url_context.referent.metadata)
      mapping[:note] = note
      mapping
    end

    private

      ## below take from Umlaut's illiad service adaptor
      # https://github.com/team-umlaut/umlaut/blob/master/app/service_adaptors/illiad.rb
      # takes an existing openURL and illiad-izes it.
      # also attempts to handle the question of enumeration.
      def illiad_query_parameters(referrer:, referent:, metadata:, note:)
        qp = map_metdata(referrer:, referent:, metadata:)
        qp['notes'] = note

        # trim empty ones please
        qp.delete_if { |_k, v| v.blank? }
        qp.to_query
      end

      # rubocop:disable Metrics/MethodLength
      def map_metdata(referrer:, referent:, metadata:)
        qp = {}
        METADATA_MAPPING.each { |metadata_key, illiad_key| qp[illiad_key] = metadata[metadata_key.to_s] }

        ## Possible enumeration values
        # qp['month']     = get_month(referent)
        qp = au_params(metadata:, qp:)
        # ILLiad always wants 'title', not the various title keys that exist in OpenURL
        # For some reason these go to ILLiad prefixed with rft.
        qp['title'] = [metadata['jtitle'], metadata['btitle'], metadata['title']].find(&:present?)
        qp['volume'] = enum
        qp['issue']  = chron
        qp['sid'] = sid_for_illiad(referrer)
        qp['rft_id'] = get_oclcnum(referent)
        qp['rft.callnum'] = call_number
        qp['rft.oclcnum'] = get_oclcnum(referent)
        qp['genre'] = genere(format: referent.format, qp:)
        qp['CitedIn'] = catalog_url(referent)
        qp
      end
      # rubocop:enable Metrics/MethodLength

      # Grab a source label out of `sid` or `rfr_id`, add on our suffix.
      def sid_for_illiad(referrer)
        sid = referrer.identifiers.first || ""
        sid = sid.gsub(%r{\Ainfo\:sid/}, '')
        "#{sid}#{@sid_suffix}"
      end

      ## From https://github.com/team-umlaut/umlaut/blob/master/app/mixin_logic/metadata_helper.rb
      def get_oclcnum(rft)
        get_identifier(:info, "oclcnum", rft)
      end

      def catalog_url(referent)
        bibidata_url = URI(referent.identifiers.first)
        bibid = bibidata_url.path.split('/').last
        "#{Requests::Config[:pulsearch_base]}/catalog/#{bibid}"
      end

      def get_lccn(rft)
        get_identifier(:info, "lccn", rft)
      end

      def get_identifier(type, sub_scheme, referent, options = {})
        options[:multiple] ||= false
        identifiers = identifiers_for_type(type:, sub_scheme:, referent:)
        if identifiers.blank? && ['lccn', 'oclcnum', 'isbn', 'issn', 'doi', 'pmid'].include?(sub_scheme)
          # try the referent metadata
          from_rft = referent.metadata[sub_scheme]
          identifiers = [from_rft] if from_rft.present?
        end
        if options[:multiple]
          identifiers
        elsif identifiers[0].blank?
          nil
        else
          identifiers[0]
        end
      end
      ### end code from umlaut

      def identifiers_for_type(type:, sub_scheme:, referent:)
        raise Exception, "type must be :urn or :info" unless (type == :urn) || (type == :info)
        prefix = case type
                 when :info then "info:#{sub_scheme}/"
                 when :urn  then "urn:#{sub_scheme}:"
                 end
        referent.identifiers.collect { |id| Regexp.last_match(1) if id =~ /^#{prefix}(.*)/ }.compact
      end

      def au_params(metadata:, qp:)
        if metadata['aulast']
          qp["rft.aulast"] = metadata['aulast']
          qp["rft.aufirst"] = [metadata['aufirst'], metadata["auinit"]].find(&:present?)
        else
          qp["rft.au"] = metadata["au"]
        end
        qp
      end

      # Genre normalization. ILLiad pays a lot of attention to `&genre`, but
      # doesn't use actual OpenURL rft_val_fmt
      def genere(format:, qp:)
        if format == "dissertation"
          'dissertation'
        elsif qp['isbn'].present? && qp['genre'] == 'book' && qp['atitle'] && qp['issn'].blank?
          # actually a book chapter, not a book, fix it.
          'bookitem'
        elsif qp['issn'].present? && qp['atitle'].present?
          # Otherwise, if there is an ISSN, we force genre to 'article', seems
          # to work best.
          'article'
        elsif qp['genre'] == 'unknown' && qp['atitle'].blank?
          # WorldCat likes to send these, ILLiad is happier considering them 'book'
          "book"
        else
          qp['genre']
        end
      end
  end
end
