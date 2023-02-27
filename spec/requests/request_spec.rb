# frozen_string_literal: true

require 'rails_helper'
require 'faraday'

describe 'blacklight tests' do
  include ApplicationHelper

  before do
    stub_holding_locations
  end

  describe 'ICU folding keyword search' do
    it 'finds an Arabic entry from a Romanized search term' do
      get '/catalog.json?&search_field=all_fields&q=dawwani'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9947053043506421' }).to eq true
    end
  end

  describe 'advanced handling when multiple fields' do
    it 'handles it' do
      get '/catalog.json?f1=title&f2=author&f3=title&op2=AND&op3=AND&q1=&q2=Murakami%2C+Haruki&q3=1Q84&search_field=advanced'
      r = JSON.parse(response.body)
      expect(r['data'].length).to eq 3
    end
  end

  describe 'NOT tests' do
    it 'ignores lowercase' do
      get '/catalog.json?search_field=all_fields&q=demeter+does+not+remember'
      r = JSON.parse(response.body)
      expect(r['data'].length).to eq 1
    end
    it 'parses NOT right' do
      get '/catalog.json?search_field=all_fields&q=demeter+does+NOT+remember'
      r = JSON.parse(response.body)
      expect(r['data'].length).to eq 0
    end
    it 'can search for all caps' do
      get '/catalog.json?search_field=all_fields&q=DEMETER+DOES+NOT+REMEMBER'
      r = JSON.parse(response.body)
      expect(r['data'].length).to eq 1
    end
  end

  describe 'Multiple locations check' do
    before { stub_holding_locations }

    it 'records with 3 or more holdings indicate that the record view has full availability' do
      get '/catalog/998574693506421/raw'
      r = JSON.parse(response.body)
      expect(r['location'].length).to be > 2
      get '/catalog?&search_field=all_fields&q=998574693506421'
      expect(response.body).to include '<span style="font-size: small; font-style: italic;">View record for information on additional holdings</span>'
    end
    it 'displays the location name for an item with a single location' do
      get '/catalog/993213506421/raw'
      r = JSON.parse(response.body)
      expect(r['location_display'].length).to eq 1
      location = r['location_display'][0]
      get '/catalog?&search_field=all_fields&q=993213506421'
      expect(response.body.include?(location.to_s)).to eq true
    end
  end

  describe 'Urlify check' do
    before { stub_holding_locations }

    it 'links to an electronic resource with the appropriate display text' do
      get '/catalog/9933506421'
      expect(response.body).to include("<a target=\"_blank\" rel=\"noopener\" href=\"#{Requests.config['proxy_base']}http://d-nb.info/991834119/04\">Inhaltsverzeichnis</a>")
    end

    it 'includes $z as an additional label for the link' do
      get '/catalog/998449623506421'
      expect(response.body).to(
        include('Finding aid online:: <a target="_blank" rel="noopener" href="https://library.princeton.edu/resolve/lookup?url=http://arks.princeton.edu/ark:/88435/pz50gw142">arks.princeton.edu</a>')
      )
    end

    it 'includes the link for online holdings in search results' do
      get '/catalog?&search_field=all_fields&q=9990889283506421'
      expect(response.body).to include("<a target=\"_blank\" rel=\"noopener\" href=\"#{Requests.config['proxy_base']}http://doi.org/10.3886/ICPSR35465\">doi.org</a>")
    end
  end

  describe 'pul_holdings check' do
    it 'excludes scsb items when pul location filter is applied' do
      get '/catalog.json?per_page=100&f_inclusive%5Badvanced_location_s%5D%5B%5D=pul'
      expect(response.body).to include('"99118884033506421"')
      expect(response.body).not_to include('"SCSB-2143785"')
    end
  end

  describe 'stackmap link check' do
    it 'provides a link to locate an item for each holding' do
      stub_holding_locations
      get '/catalog/994304723506421/raw'
      r = JSON.parse(response.body)
      get '/catalog/994304723506421'
      r['location_code_s'].each do |location|
        expect(response.body).to include("data-map-location=\"#{location}")
      end
    end
    it 'does not provide a find it link for online holdings' do
      get '/catalog/9990889283506421'
      expect(response.body.include?('[Where to Find it]')).to eq false
    end
  end

  SEPARATOR = '—'
  describe 'subjectify check' do
    it 'provides links to facet search based on hierarchy' do
      stub_holding_locations
      get '/catalog/9961398363506421/raw'
      r = JSON.parse(response.body)
      sub_component = []
      fullsubject = r['lc_subject_display']
      fullsubject.each do |subject|
        sub_component << subject.split(SEPARATOR)
      end
      get '/catalog/9961398363506421'
      fullsubject.each_with_index do |subject, i|
        sub_component[i].each do |component|
          c = Regexp.escape(component)
          expect(response.body).to include('class="search-subject" data-toggle="'\
                                        'tooltip" data-original-title="Search: '\
                                        "#{subject[/.*#{c}/]}\" title=\"Search: "\
                                        "#{subject[/.*#{c}/]}\" href=\"/?f[subject_facet][]="\
                                        "#{CGI.escape subject[/.*#{c}/]}\">"\
                                        "#{component}</a>")
        end
      end
    end
  end

  describe 'dir tag check' do
    before { stub_holding_locations }

    it 'adds rtl dir for title and author field in search results' do
      get '/catalog/9947053043506421/raw'
      r = JSON.parse(response.body)
      title_vern = r['title_vern_display']
      author = r['author_display'][0]
      author_vern = r['author_display'][1]
      doc_id = r['id']
      get '/catalog?&search_field=all_fields&q=9947053043506421'
      expect(response.body).to include('dir="rtl" style="float: right;" href="'\
                                    "/catalog/#{doc_id}\">#{title_vern}</a>")
      expect(response.body).to include('<li class="blacklight-author_display" dir="ltr"><a class="search-name" data-toggle="'\
                                    "tooltip\" data-original-title=\"Search: #{author}\" title"\
                                    "=\"\" href=\"/?f[author_s][]=#{CGI.escape author}\">"\
                                    "#{author}</a>")
      expect(response.body).to include('<li class="blacklight-author_display" dir="rtl"><a class="search-name" data-toggle="'\
                                    "tooltip\" data-original-title=\"Search: #{author_vern}\" "\
                                    "title=\"\" href=\"/?f[author_s][]="\
                                    "#{CGI.escape author_vern}\">#{author_vern}</a>")
    end
    it 'adds ltr rtl dir for title and other fields in document view' do
      get '/catalog/9947053073506421/raw'
      r = JSON.parse(response.body)
      title_vern = r['title_vern_display']
      note = r['notes_display'][0]
      note_vern = r['notes_display'].last
      get '/catalog/9947053073506421'
      expect(response.body).to include("<h1 dir=\"rtl\" lang=\"ar\"> #{title_vern} </h1>")
      expect(response.body).to include("<li class=\"blacklight-notes_display\" dir=\"ltr\">#{note}</li>")
      expect(response.body).to include("<li class=\"blacklight-notes_display\" dir=\"rtl\">#{note_vern}</li>")
    end
  end

  describe 'left-anchor tests' do
    it 'finds result despite accents and capitals in query' do
      get '/catalog.json?&search_field=left_anchor&q=s%C3%A8arChing+for'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9965749873506421' }).to eq true
    end

    it "no matches if it doesn't occur at the beginning of the starts with fields" do
      get '/catalog.json?&search_field=left_anchor&q=modern+aesthetic'
      r = JSON.parse(response.body)
      expect(r['meta']['pages']['total_count']).to eq 0
    end

    it 'page loads without erroring when query is not provided' do
      get '/catalog.json?per_page=100&search_field=left_anchor'
      expect(response.status).to eq(200)
    end

    it 'works in advanced search' do
      get '/catalog.json?&search_field=advanced&f1=left_anchor&q1=searching+for&op2=AND&f2=left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9965749873506421' }).to eq true
    end

    context 'with punctuation marks in the title' do
      it 'handles whitespace characters padding punctuation' do
        get '/catalog.json?search_field=left_anchor&q=JSTOR+%5Belectronic+resource%5D+%3A'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true

        get '/catalog.json?search_field=left_anchor&q=JSTOR+%5Belectronic+resource%5D%3A'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
      end
    end

    context 'with user-supplied * in query string' do
      it 'are handled in simple search' do
        get '/catalog.json?search_field=left_anchor&q=JSTOR*'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
      end
      it 'are handled in advanced search' do
        get '/catalog.json?f1=left_anchor&q1=JSTOR*&search_field=advanced'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
      end
    end

    context 'solr operator characters' do
      it 'are handled in simple search' do
        get '/catalog.json?search_field=left_anchor&q=JSTOR%7B%7D%3A%26%26%7C%7C"%2B%5E~-%2F%3F+%5BElectronic+Resource%5D'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
      end
      it 'are handled in advanced search' do
        get '/catalog.json?f1=left_anchor&q1=JSTOR%7B%7D%3A%26%26%7C%7C"%2B%5E~-%2F%3F+%5BElectronic+Resource%5D&search_field=advanced'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
      end
    end

    context 'cjk characters' do
      it 'are searchable in simple search' do
        get "/catalog.json?search_field=left_anchor&q=#{CGI.escape('浄名玄論 / 京都国立博物館編 ; 解說石塚晴道 (北海道大学名誉教授)')}"
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9981818493506421' }).to eq true
      end
      it 'are searchable in advanced search' do
        get "/catalog.json?f1=left_anchor&q1=#{CGI.escape('浄名玄論 / 京都国立博物館編 ; 解說石塚晴道 (北海道大学名誉教授)')}&search_field=advanced"
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9981818493506421' }).to eq true
      end
    end
  end

  describe 'advanced search tests' do
    it 'supports advanced render constraints' do
      stub_holding_locations
      get '/catalog?&search_field=advanced&f1=left_anchor&q1=searching+for1&op2=AND&f2='\
          'left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for'
      expect(response.body).to include 'Remove constraint Title starts with: searching for1'
      get '/catalog.json?&search_field=advanced&f1=left_anchor&q1=searching+for1&op2=AND&f2='\
          'left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9965749873506421' }).to eq false
      get '/catalog?f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=advanced'
      expect(response.body).not_to include 'Remove constraint Title starts with: searching for1'
      get '/catalog.json?f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=advanced'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9965749873506421' }).to eq true
    end
    it 'does not error when only the 3rd query field has a value' do
      get '/catalog?f1=all_fields&q1=&op2=AND&f2=author&q2=&op3=AND&f3=title&q3='\
          'anything&search_field=advanced&commit=Search'
      expect(response.status).to eq(200)
    end
    it 'does not error when there are stray quotation marks' do
      get '/catalog?f1=all_fields&q1="b"&op2=AND&f2=author&q2=a"&op3=AND&f3=title&q3='\
          'anythi"ng&search_field=advanced&commit=Search'
      expect(response.status).to eq(200)
    end
    it 'successful search when the 1st and 3rd query are same field, 2nd query field different' do
      get '/catalog?f1=all_fields&q1=something&op2=AND&f2=author&q2=&op3=OR&f3=all_fields&q3='\
          'anything&search_field=advanced&commit=Search'
      expect(response.status).to eq(200)
    end
    it 'title starts with can be ORed across several 3 queries' do
      get '/catalog.json?f1=left_anchor&q1=Reconstructing+the&op2=OR&f2=left_anchor&q2='\
          'This+angel+on&op3=OR&f3=left_anchor&q3=Almost+Human&search_field=advanced&commit=Search'
      r = JSON.parse(response.body)
      doc_ids = %w[9992220243506421 9222024 dsp01ft848s955 dsp017s75dc44p]
      expect(r['data'].all? { |d| doc_ids.include?(d['id']) }).to eq true
    end

    context 'with punctuation marks in the title' do
      it 'handles whitespace characters padding punctuation in the left_anchor field' do
        get '/catalog.json?f1=left_anchor&q1=JSTOR+%5Belectronic+resource%5D+%3A&op2='\
            'AND&f2=author&q2=&op3=AND&f3=title&q3=&range%5Bpub_date_start_sort%5D%5Bbegin%5D='\
            '&range%5Bpub_date_start_sort%5D%5Bend%5D=&sort=score+desc%2C+pub_date_start_sort'\
            '+desc%2C+title_sort+asc&search_field=advanced&commit=Search'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true

        get '/catalog.json?f1=left_anchor&q1=JSTOR+%5Belectronic+resource%5D%3A&op2='\
            'AND&f2=author&q2=&op3=AND&f3=title&q3=&range%5Bpub_date_start_sort%5D%5Bbegin%5D='\
            '&range%5Bpub_date_start_sort%5D%5Bend%5D=&sort=score+desc%2C+pub_date_start_sort'\
            '+desc%2C+title_sort+asc&search_field=advanced&commit=Search'
        r = JSON.parse(response.body)
        expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
      end
    end
  end

  describe 'staff view' do
    it 'marcxml matches bibdata marcxml for record' do
      id = '9965749873506421'
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{id}")
        .to_return(status: 200,
                   body: File.read(File.join(fixture_path, 'bibdata', "#{id}.xml")))
      get "/catalog/#{id}.marcxml"
      staff_view = response.body
      bibdata = Faraday.get("#{Requests.config['bibdata_base']}/bibliographic/#{id}").body
      expect(staff_view).to eq bibdata
    end
  end

  describe 'jsonld view' do
    it 'creates a jsonld view from solr' do
      id = '9965749873506421'
      get "/catalog/#{id}.jsonld"
      expect(response.status).to eq 200
    end
  end

  describe 'identifier metadata' do
    before { stub_holding_locations }

    it 'is accessible from show view' do
      id = '9979160443506421'
      get "/catalog/#{id}"
      expect(response.body).to include '<meta property="isbn"'
      expect(response.body).to include 'data-isbn="['
    end
    it 'is accessible from search results' do
      get '/catalog?search_field=all_fields'
      expect(response.body).to include '<meta property="isbn"'
      expect(response.body).to include 'data-isbn="['
    end
  end

  describe 'location metadata' do
    before { stub_holding_locations }

    it 'is accessible from show view' do
      id = '9979160443506421'
      get "/catalog/#{id}"
      expect(response.body).to include('"[&quot;mudd$ph&quot;, &quot;Mudd Manuscript Library&quot;]"')
    end
  end

  describe 'homepage facets' do
    it 'Only facets configured for homepage display are requested in Solr' do
      get '/catalog.json'
      r = JSON.parse(response.body)
      facets = r['included'].select { |i| i['type'] == 'facet' }
      expect(facets.any? { |f| f['id'] == 'location' }).to eq true
      expect(facets.any? { |f| f['id'] == 'instrumentation_facet' }).to eq false
    end

    it 'All configured facets are requested in Solr within a search' do
      get '/catalog.json?search_field=all_fields&q=camilla'
      r = JSON.parse(response.body)
      facets = r['included'].select { |i| i['type'] == 'facet' }
      expect(facets.any? { |f| f['id'] == 'location' }).to eq true
      expect(facets.any? { |f| f['id'] == 'instrumentation_facet' }).to eq true
    end
  end

  describe 'other versions' do
    it 'provides links to other versions of record when they are found' do
      get '/catalog/9952918833506421'
      expect(response.body).not_to include('href="http://www.example.com/catalog/9952918833506421"')
      expect(response.body).to include('href="http://www.example.com/catalog/99125344809306421"')
      expect(response.body).to include('href="http://www.example.com/catalog/SCSB-10422725"')
      get '/catalog/99125344809306421'
      expect(response.body).not_to include('href="http://www.example.com/catalog/99125344809306421"')
      expect(response.body).to include('href="http://www.example.com/catalog/9952918833506421"')
      expect(response.body).to include('href="http://www.example.com/catalog/SCSB-10422725"')
    end
    it 'provides link to linked related record (774 bib link) when found' do
      stub_holding_locations
      get '/catalog/9947053043506421'
      expect(response.body).to include('href="http://www.example.com/catalog/9947053073506421"')
    end
    it 'provides link to record in which current record is contained (773 bib link) when found' do
      stub_holding_locations
      get '/catalog/9947053073506421'
      expect(response.body).to include('href="http://www.example.com/catalog/9947053043506421"')
    end
    it 'provides link to other version of the record when linked via bib id in 776/787' do
      get '/catalog/9934788983506421'
      expect(response.body).to include('href="http://www.example.com/catalog/9938615393506421"')
    end
    it 'does not provide link to bib id in 776/787 if linked record does not exist' do
      stub_holding_locations
      get '/catalog/998574693506421/raw'
      linked_bib = '00368075'
      r = JSON.parse(response.body)
      expect(r['other_version_s']).to include(linked_bib)
      get '/catalog/998574693506421'
      expect(response.body).not_to include("href=\"http://www.example.com/catalog/#{linked_bib}\"")
    end
  end

  describe 'standard no search' do
    it 'resolves to record represented by standard number' do
      get '/catalog/issn/0082-9455'
      expect(response).to redirect_to('/catalog/994916543506421')
      get '/catalog/isbn/9781303457036'
      expect(response).to redirect_to('/catalog/9979160443506421')
      get '/catalog/oclc/650437639'
      expect(response).to redirect_to('/catalog/9961398363506421')
      get '/catalog/lccn/2007018609'
      expect(response).to redirect_to('/catalog/9952918833506421')
    end
    it 'redirects to keyword search if record not found' do
      get '/catalog/issn/blah'
      expect(response).to redirect_to('/catalog?q=blah')
      get '/catalog/isbn/blob'
      expect(response).to redirect_to('/catalog?q=blob')
      get '/catalog/lccn/super'
      expect(response).to redirect_to('/catalog?q=super')
      get '/catalog/oclc/cool'
      expect(response).to redirect_to('/catalog?q=cool')
    end
  end

  describe 'voyager record url pattern' do
    it 'redirects to blacklight catalog url' do
      get '/cgi-bin/Pwebrecon.cgi?BBID=12345'
      expect(response).to redirect_to('/catalog/12345')
      get '/cgi-bin/Pwebrecon.cgi?bbid=12345'
      expect(response).to redirect_to('/catalog/12345')
    end
  end

  describe 'mathjax script' do
    it 'is included in search results' do
      stub_holding_locations
      get '/?f%5Bformat%5D%5B%5D=Book&q=&search_field=all_fields'
      expect(response.body).to include('MathJax.js')
    end
    it 'is included on theses record show page' do
      get '/catalog/dsp01ft848s955'
      expect(response.body).to include('MathJax.js')
    end
    it 'is excluded on marc record show page' do
      stub_holding_locations
      get '/catalog/4705307'
      expect(response.body).not_to include('mathjax.org')
    end
  end

  describe 'escaping search/browse link urls' do
    before { stub_holding_locations }

    it 'search result name facet/browse urls' do
      get '/?f%5Blocation%5D%5B%5D=East+Asian+Library'
      expect(response.body).to include('/?f[author_s][]=%E5%8D%8E%E6%83%A0%E4%BC%A6.')
      expect(response.body).to include('/browse/names?q=%E5%8D%8E%E6%83%A0%E4%BC%A6.')
    end
    it 'show page subject facet/browse, call number browse urls' do
      get '/catalog/9948322283506421'
      expect(response.body).to include('/browse/subjects?q=Mencius%E2%80%94%E5%AD%9F%E5%AD%90.')
      expect(response.body).to include('/?f[subject_facet][]=Mencius%E2%80%94%E5%AD%9F%E5%AD%90.')
      expect(response.body).to include('/browse/call_numbers?q=C338%2F4352+vol.500')
    end
    it 'show page related name facet/browse urls' do
      get '/catalog/9938713983506421'
      expect(response.body).to include('/?f[author_s][]=%E7%A5%9D%E7%A9%86%2C+13th+cent')
      expect(response.body).to include('/browse/names?q=%E7%A5%9D%E7%A9%86%2C+13th+cent')
    end

    it 'show page name-title facet/browse urls' do
      get '/catalog/998574693506421'
      expect(response.body).to include('/?f[name_title_browse_s][]=Helminthological+Society+of+'\
                                       'Washington.+Proceedings+of+the+Helminthological+Society+'\
                                       'of+Washington')
      expect(response.body).to include('/browse/name_titles?q=Helminthological+Society+of+'\
                                       'Washington.+Proceedings+of+the+Helminthological+Society+'\
                                       'of+Washington')
    end
    it 'url does not appear for linked titles with no subfield $a' do
      get '/catalog/998574693506421'
      expect(response.body).to include('Science (New York, N.Y.)')
      expect(response.body).not_to include('/?f[name_title_browse_s][]=Science+%28New+York%2C+N.Y.%29')
      expect(response.body).not_to include('/browse/name_titles?q=Science+%28New+York%2C+N.Y.%29')
    end
  end

  describe 'series_display in search results' do
    it 'is fetched when doing a more in this series search' do
      get '/catalog.json?q1=Always+learning.&f1=in_series&search_field=advanced'
      r = JSON.parse(response.body)
      expect(r['data'].find { |d| d['id'] == '9979171923506421' }['attributes']['series_display']).not_to be_nil
    end
    it 'is displayed when doing a series title search' do
      stub_holding_locations
      get '/catalog/9979171923506421/raw'
      r = JSON.parse(response.body)
      series_title = r['series_display']
      get '/catalog?q3=Always+learning&f3=series_title&search_field=advanced'
      expect(response.body).to include(series_title.join(', '))
    end
    it 'is not included in other search contexts' do
      get '/catalog.json?q=9979171923506421&search_field=all_fields'
      r = JSON.parse(response.body)
      expect(r['data'].find { |d| d['id'] == '9979171923506421' }['attributes']['series_display']).to be_nil
    end
  end

  describe 'notes field in advanced search' do
    it 'record with notes field is retrieved' do
      get '/catalog.json?q1=minhas+entre&f1=notes&search_field=advanced'
      r = JSON.parse(response.body)
      expect(r['data'].count { |d| d['id'] == '991639143506421' }).to eq(1)
    end
  end

  describe 'voyager login url pattern' do
    it 'redirects to the account page' do
      get '/cgi-bin/Pwebrecon.cgi?PAGE=pbLogon'
      expect(response).to redirect_to('/account')
    end
  end

  describe 'numismatics advanced search' do
    it 'only returns coin records' do
      get '/catalog.json?advanced_type=numismatics&q=*'
      r = JSON.parse(response.body)
      expect(r['data'].length).to eq 3
    end
  end

  describe "bento search JSON API requirements" do
    it "returns electronic_portfolio_s" do
      get "/catalog.json?q=99122306151806421"
      json = JSON.parse(response.body)

      expect(json["data"][0]["attributes"]["electronic_portfolio_s"]).not_to be_blank
    end
  end
end
