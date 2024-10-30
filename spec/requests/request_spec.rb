# frozen_string_literal: true

require 'rails_helper'
require 'faraday'

describe 'blacklight tests' do
  include ApplicationHelper

  before { stub_holding_locations }

  describe 'ICU folding keyword search' do
    it 'finds an Arabic entry from a Romanized search term' do
      get '/catalog.json?&search_field=all_fields&q=dawwani'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9947053043506421' }).to eq true
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
      expect(response.body).to include 'View Record for Full Availability'
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
      expect(response.body).to include("<a target=\"_blank\" rel=\"noopener\" href=\"http://d-nb.info/991834119/04\">Inhaltsverzeichnis<i class=\"fa fa-external-link new-tab-icon-padding\" aria-label=\"opens in new tab\" role=\"img\"></i></a>")
    end

    it 'includes $z as an additional label for the link' do
      get '/catalog/998449623506421'
      expect(response.body).to(
        include('Finding aid online:: <a target="_blank" rel="noopener" href="http://arks.princeton.edu/ark:/88435/pz50gw142">arks.princeton.edu<i class="fa fa-external-link new-tab-icon-padding" aria-label="opens in new tab" role="img"></i></a>')
      )
    end

    it 'includes the link for online holdings in search results' do
      get '/catalog?&search_field=all_fields&q=998574693506421'
      expect(response.body).to include("<a target=\"_blank\" rel=\"noopener\" href=\"#{Requests.config['proxy_base']}http://catalog.hathitrust.org/Record/008883092\">catalog.hathitrust.org</a>")
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
      expect(response.body.include?('[Where to find it]')).to eq false
    end
  end

  SEPARATOR = '—'
  describe 'subjectify check' do
    it 'provides links on LC subject headings to facet search based on hierarchy' do
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
          expect(response.body).to include('class="search-subject" '\
                                        'data-original-title="Search: '\
                                        "#{subject[/.*#{c}/]}\" "\
                                        "href=\"/?f[subject_facet][]="\
                                        "#{CGI.escape subject[/.*#{c}/]}\">"\
                                        "#{component}</a>")
        end
      end
    end
    it 'provides links on FaST subject headings to facet search based on hierarchy' do
      stub_holding_locations
      get '/catalog/99125527882306421/raw'
      r = JSON.parse(response.body)
      sub_component = []
      fullsubject = r['fast_subject_display']
      fullsubject.each do |subject|
        sub_component << subject.split(SEPARATOR)
      end
      get '/catalog/99125527882306421'
      fullsubject.each_with_index do |_subject, i|
        sub_component[i].each do |component|
          Regexp.escape(component)
          expect(response.body).to include("class=\"search-subject\" data-original-title=\"Search: Criticism, interpretation, etc.\" href=\"/?f[subject_facet][]=Criticism%2C+interpretation%2C+etc\">Criticism, interpretation, etc.</a>  </li><li dir=\"ltr\">")

          expect(response.body).not_to include('href=\"/browse/subjects?q=Criticism%2C+interpretation%2C+etc.\"')
        end
      end
    end
  end

  describe 'dir tag check' do
    before do
      stub_holding_locations
      allow(Flipflop).to receive(:highlighting?).and_return(false)
    end

    it 'adds rtl dir for title and author field in search results' do
      get '/catalog/9947053043506421/raw'
      r = JSON.parse(response.body)
      title_vern = r['title_vern_display']
      author = r['author_display'][0]
      author_vern = r['author_display'][1]
      doc_id = r['id']
      get '/catalog?&search_field=all_fields&q=9947053043506421'
      expect(response.body).to include('style="float: right;" dir="rtl" href="'\
                                    "/catalog/#{doc_id}\">#{title_vern}</a>")
      expect(response.body).to include('<li class="blacklight-author_display" dir="ltr"><a class="search-name" '\
                                    "data-original-title=\"Search: #{author}\" "\
                                    "href=\"/?f[author_s][]=#{CGI.escape author}\">"\
                                    "#{author}</a>")
      expect(response.body).to include('<li class="blacklight-author_display" dir="rtl"><a class="search-name" '\
                                    "data-original-title=\"Search: #{author_vern}\" "\
                                    "href=\"/?f[author_s][]="\
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

  describe 'advanced search tests' do
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
  end

  describe 'staff view' do
    it 'marcxml matches bibdata marcxml for record' do
      id = '9965749873506421'
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{id}")
        .to_return(status: 200,
                   body: File.read(File.join(fixture_paths.first, 'bibdata', "#{id}.xml")))
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

  describe 'identifier metadata', thumbnails: true do
    before { stub_holding_locations }

    it 'is accessible from show view' do
      id = '99125476820706421'
      get "/catalog/#{id}"
      expect(response.body).to include '<meta property="isbn"'
      expect(response.body).to include 'data-isbn="['
    end
    it 'is accessible from search results' do
      get '/catalog?search_field=all_fields&q='
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

  describe 'escaping search/browse link urls', browse: true do
    before do
      stub_holding_locations
      allow(Flipflop).to receive(:highlighting?).and_return(false)
    end

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
      get '/catalog.json?advanced_type=advanced&clause[0][field]=series_title&clause[0][query]=Always+learning'
      r = JSON.parse(response.body)
      expect(r['data'].find { |d| d['id'] == '9979171923506421' }['attributes']['series_display']).not_to be_nil
    end
    it 'is displayed when doing a series title search' do
      stub_holding_locations
      get '/catalog/9979171923506421/raw'
      r = JSON.parse(response.body)
      series_title = r['series_display']

      get '/catalog.json?advanced_type=advanced&clause[0][field]=series_title&clause[0][query]=Always+learning'
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
      get '/catalog.json?advanced_type=advanced&clause[0][field]=notes&clause[0][query]=minhas+entre'
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

  describe 'search algorithm selection' do
    before do
      allow(Flipflop).to receive(:multi_algorithm?).and_return(true)
    end

    context "when the search_algorithm parameter is not present" do
      it "ranks using the default request handler" do
        get "/catalog.json?q=roman"
        json = JSON.parse(response.body)

        expect(json["data"][0]["attributes"]["title"]).to eq "Ogonek : roman / ."
      end
    end

    context "when the search_algorithm parameter is set to 'engineering'" do
      it "ranks using the engineering request handler" do
        get "/catalog.json?q=roman&search_algorithm=engineering"
        json = JSON.parse(response.body)

        expect(json["data"][0]["attributes"]["title"]).to eq "Reconstructing the Vitruvian Scorpio: An Engineering Analysis of Roman Field Artillery"
      end
    end

    context "advanced search and jsonld are enabled" do
      # TODO: what should this really do?  Should the advanced search and jsonld get turned off when an algorithm is swapped
      #       Should we see if we can combine the search handlers by adding a query parameter, or make a combined handler that has both?
      it "retuns the jsonld result not the engineering result" do
        get "/catalog.json?utf8=%E2%9C%93&clause%5B0%5D%5Bfield%5D=all_fields&clause%5B0%5D%5Bquery%5D=roman&clause%5B1%5D%5Bop%5D=must&clause%5B1%5D%5Bfield%5D=author&clause%5B1%5D%5Bquery%5D=&clause%5B2%5D%5Bop%5D=must&clause%5B2%5D%5Bfield%5D=title&clause%5B2%5D%5Bquery%5D=&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&sort=score+desc%2C+pub_date_start_sort+desc%2C+title_sort+asc&commit=Search&search_algorithm=engineering"
        json = JSON.parse(response.body)
        expect(json["data"][0]["attributes"]["title"]).to eq "Ogonek : roman / ."
      end
    end
  end
end
