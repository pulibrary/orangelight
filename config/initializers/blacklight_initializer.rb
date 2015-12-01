# A secret token used to encrypt user_id's in the Bookmarks#export callback URL
# functionality, for example in Refworks export of Bookmarks. In Rails 4, Blacklight
# will use the application's secret key base instead.
#

# Blacklight.secret_key = '97ccd2bbcdf62fd419cc257f3aad8be90f41fcae39cb710847d6191723a354bd033aad2d4d034cae8166697ea432853491ee1e9688d33b4659c26ce4bf4c647b'
require 'faraday'

module Blacklight::Solr::Document::Marc
  def marc_record_from_marcxml
    id = fetch(_marc_source_field)
    record = Faraday.get("https://bibdata.princeton.edu/bibliographic/#{id}").body
    MARC::XMLReader.new(StringIO.new( record )).to_a.first || MARC::Record.new
  end

  def export_as_openurl_ctx_kev(format = nil)  
    title = to_marc.find{|field| field.tag == '245'}
    author = to_marc.find{|field| field.tag == '100'}
    corp_author = to_marc.find{|field| field.tag == '110'}
    publisher_info = to_marc.find{|field| field.tag == '260'}
    edition = to_marc.find{|field| field.tag == '250'}
    isbn = to_marc.find{|field| field.tag == '020'}
    issn = to_marc.find{|field| field.tag == '022'}
    id = to_marc.find{|field| field.tag == '001'}
    unless format.nil?
      format.is_a?(Array) ? format = format[0].downcase.strip : format = format.downcase.strip
      genre = format_to_openurl_genre(format)
    end
    export_text = ""
    if format == 'book'
      export_text << "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=book&amp;"
      export_text << "rft.btitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
      export_text << "rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
      export_text << "rft.au=#{(author.nil? or author['a'].nil?) ? "" : CGI::escape(author['a'])}&amp;"
      export_text << "rft.aucorp=#{CGI::escape(corp_author['a']) if corp_author['a']}+#{CGI::escape(corp_author['b']) if corp_author['b']}&amp;" unless corp_author.blank?
      export_text << "rft.date=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&amp;"
      export_text << "rft.place=#{(publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a'])}&amp;"
      export_text << "rft.pub=#{(publisher_info.nil? or publisher_info['b'].nil?) ? "" : CGI::escape(publisher_info['b'])}&amp;"
      export_text << "rft.edition=#{(edition.nil? or edition['a'].nil?) ? "" : CGI::escape(edition['a'])}&amp;"
      export_text << "rft.isbn=#{(isbn.nil? or isbn['a'].nil?) ? "" : isbn['a']}"
      export_text << "&amp;rft.genre=book"
    elsif (format =~ /journal/i) # checking using include because institutions may use formats like Journal or Journal/Magazine
      export_text << "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;rft.genre=article&amp;"
      export_text << "rft.title=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
      export_text << "rft.atitle=#{(title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a'])}+#{(title.nil? or title['b'].nil?) ? "" : CGI::escape(title['b'])}&amp;"
      export_text << "rft.aucorp=#{CGI::escape(corp_author['a']) if corp_author['a']}+#{CGI::escape(corp_author['b']) if corp_author['b']}&amp;" unless corp_author.blank?
      export_text << "rft.date=#{(publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c'])}&amp;"
      export_text << "rft.issn=#{(issn.nil? or issn['a'].nil?) ? "" : issn['a']}"
      export_text << "&amp;rft.genre=serial"
    else
      export_text << "ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator&amp;"
      export_text << "rft.title=" + ((title.nil? or title['a'].nil?) ? "" : CGI::escape(title['a']))
      export_text <<  ((title.nil? or title['b'].nil?) ? "" : CGI.escape(" ") + CGI::escape(title['b']))
      export_text << "&amp;rft.creator=" + ((author.nil? or author['a'].nil?) ? "" : CGI::escape(author['a']))
      export_text << "&amp;rft.aucorp=#{CGI::escape(corp_author['a']) if corp_author['a']}+#{CGI::escape(corp_author['b']) if corp_author['b']}" unless corp_author.blank?
      export_text << "&amp;rft.date=" + ((publisher_info.nil? or publisher_info['c'].nil?) ? "" : CGI::escape(publisher_info['c']))
      export_text << "&amp;rft.place=" + ((publisher_info.nil? or publisher_info['a'].nil?) ? "" : CGI::escape(publisher_info['a']))
      export_text << "&amp;rft.pub=" + ((publisher_info.nil? or publisher_info['b'].nil?) ? "" : CGI::escape(publisher_info['b']))
      export_text << "&amp;rft.format=" + (format.nil? ? "" : CGI::escape(format))
      export_text << "&amp;rft.genre=#{genre}"
      unless issn.nil?
        export_text << "&amp;rft.issn=#{(issn.nil? or issn['a'].nil?) ? "" : issn['a']}"
      end
      unless isbn.nil?
        export_text << "&amp;rft.isbn=#{(isbn.nil? or isbn['a'].nil?) ? "" : isbn['a']}"
      end
    end
    export_text << "&amp;rft_id=" + (id.nil? ? "" : CGI::escape("pul_"+id.value))
    export_text.html_safe unless export_text.blank?
  end

  def format_to_openurl_genre(format)
    return "book" if format == "book"
    return "bookitem" if format == "book"
    return "journal" if format == "serial"
    return "conference" if format == "conference"
    return "unknown"
  end

end


# Override until this behavior is part of next Blacklight release
module Blacklight::SolrResponse::Spelling
  class Base
    # returns an array of spelling suggestion for specific query words,
    # as provided in the solr response.  Only includes words with higher
    # frequency of occurrence than word in original query.
    # can't do a full query suggestion because we only get info for each word;
    # combination of words may not have results.
    # Thanks to Naomi Dushay!
    def words
      @words ||= (
        word_suggestions = []
        spellcheck = self.response[:spellcheck]
        if spellcheck && spellcheck[:suggestions]
          suggestions = spellcheck[:suggestions]
          unless suggestions.nil?
            # suggestions is an array:
            #    (query term)
            #    (hash of term info and term suggestion)
            #    ...
            #    (query term)
            #    (hash of term info and term suggestion)
            #    'correctlySpelled'
            #    true/false
            #    collation
            #    (suggestion for collation)
            if suggestions.index("correctlySpelled") #if extended results
              i_stop = suggestions.index("correctlySpelled")
            elsif suggestions.index("collation")
              i_stop = suggestions.index("collation")
            else
              i_stop = suggestions.length
            end
              # step through array in 2s to get info for each term
              0.step(i_stop-1, 2) do |i|
                term = suggestions[i]
                term_info = suggestions[i+1]
                # term_info is a hash:
                #   numFound =>
                #   startOffset =>
                #   endOffset =>
                #   origFreq =>
                #   suggestion =>  [{ frequency =>, word => }] # for extended results
                #   suggestion => ['word'] # for non-extended results
                origFreq = term_info['origFreq']
                if term_info['suggestion'].first.is_a?(Hash) or suggestions.index("correctlySpelled")
                  word_suggestions << term_info['suggestion'].map do |suggestion|
                    suggestion['word'] if suggestion['freq'] > origFreq
                  end
                else
                  # only extended suggestions have frequency so we just return all suggestions
                  word_suggestions << term_info['suggestion']
                end
              end
          end
        end
        word_suggestions.flatten.compact.uniq
      )
    end

    def collation
      # FIXME: DRY up with words
      spellcheck = self.response[:spellcheck]
        if spellcheck && spellcheck[:suggestions]
          suggestions = spellcheck[:suggestions]
          unless suggestions.nil?
            if suggestions.index("collation")
              suggestions[suggestions.index("collation") + 1]
            elsif spellcheck.key?("collations")
              spellcheck['collations'].last
            end
          end
        end
    end
  end
end