require 'rails_helper'
require 'faraday'
include ApplicationHelper

describe 'blacklight tests' do
  describe 'ICU folding keyword search' do
    it 'finds an Arabic entry from a Romanized search term' do
      get '/catalog.json?&search_field=all_fields&q=dawwani'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].any? { |d| d['id'] == '4705304' }).to eq true
    end
  end

  describe 'Multiple locations check' do
    it 'records with 3 or more holdings indicate that the record view has full availability' do
      get '/catalog/857469.json'
      r = JSON.parse(response.body)
      expect(r['response']['document']['location'].length).to be > 2
      get '/catalog?&search_field=all_fields&q=857469'
      expect(response.body).to include '<a class="availability-icon label label-default more-info" '\
                                       'title="Click on the record for full availability info" '\
                                       'data-toggle="tooltip" href="/catalog/857469">View Record '\
                                       'for Full Availability</a>'
    end
    it 'displays the location name for an item with a single location' do
      get '/catalog/321.json'
      r = JSON.parse(response.body)
      expect(r['response']['document']['location_display'].length).to eq 1
      location = r['response']['document']['location_display'][0]
      get '/catalog?&search_field=all_fields&q=321'
      expect(response.body.include?(location.to_s)).to eq true
    end
  end

  describe 'Urlify check' do
    it 'links to an electronic resource with the appropriate display text' do
      get '/catalog/3'
      expect(response.body).to include("<a target=\"_blank\" href=\"#{ENV['proxy_base']}http://d-nb.info/991834119/04\">Inhaltsverzeichnis</a>")
    end

    it 'includes $z as an additional label for the link' do
      get '/catalog/844962'
      expect(response.body).to include("Finding aid: <a target=\"_blank\" href=\"#{ENV['proxy_base']}http://arks.princeton.edu/ark:/88435/pz50gw142\">arks.princeton.edu</a>")
    end

    it 'includes the link for online holdings in search results' do
      get '/catalog?&search_field=all_fields&q=9088928'
      expect(response.body).to include("<a target=\"_blank\" href=\"#{ENV['proxy_base']}http://doi.org/10.3886/ICPSR35465\">doi.org</a>")
    end
  end

  describe 'stackmap link check' do
    it 'provides a link to locate an item for each holding' do
      get '/catalog/430472.json'
      r = JSON.parse(response.body)
      docid = r['response']['document']['id']
      get '/catalog/430472'
      r['response']['document']['location_code_s'].each do |location|
        expect(response.body.include?("href=\"#{ENV['stackmap_base']}?loc=#{location}&amp;id=#{docid}\"")).to eq true
      end
    end
    it 'does not provide a find it link for online holdings' do
      get '/catalog/9088928'
      expect(response.body.include?('[Where to Find it]')).to eq false
    end
  end

  SEPARATOR = "—".freeze
  describe 'subjectify check' do
    it 'provides links to facet search based on hierarchy' do
      get '/catalog/6139836.json'
      r = JSON.parse(response.body)
      sub_component = []
      fullsubject = r['response']['document']['subject_display']
      fullsubject.each_with_index do |subject|
        sub_component << subject.split(SEPARATOR)
      end
      get '/catalog/6139836'
      fullsubject.each_with_index do |subject, i|
        sub_component[i].each do |component|
          c = Regexp.escape(component)
          expect(response.body.include?('class="search-subject" data-toggle="'\
                                        'tooltip" data-original-title="Search: '\
                                        "#{subject[/.*#{c}/]}\" title=\"Search: "\
                                        "#{subject[/.*#{c}/]}\" href=\"/?f[subject_facet][]="\
                                        "#{subject[/.*#{c}/]}\">#{component}</a>")).to eq true
        end
      end
    end
  end

  describe 'dir tag check' do
    it 'adds rtl dir for title and author field in search results' do
      get '/catalog.json?&search_field=all_fields&q=4705304'
      r = JSON.parse(response.body)['response']['docs'].select { |d| d['id'] == '4705304' }[0]
      title_vern = r['title_vern_display']
      author = r['author_display'][0]
      author_vern = r['author_display'][1]
      doc_id = r['id']
      get '/catalog?&search_field=all_fields&q=4705304'
      expect(response.body.include?('dir="rtl" style="float: right;" href="'\
                                    "/catalog/#{doc_id}\">#{title_vern}</a>")).to eq true
      expect(response.body.include?('<li dir="ltr"> <a class="search-name" data-toggle="'\
                                    "tooltip\" data-original-title=\"Search: #{author}\" title"\
                                    "=\"Search: #{author}\" href=\"/?f[author_s][]=#{author}\">"\
                                    "#{author}</a>")).to eq true
      expect(response.body.include?('<li dir="rtl"> <a class="search-name" data-toggle="'\
                                    "tooltip\" data-original-title=\"Search: #{author_vern}\" "\
                                    "title=\"Search: #{author_vern}\" href=\"/?f[author_s][]="\
                                    "#{author_vern}\">#{author_vern}</a>")).to eq true
    end
    it 'adds ltr rtl dir for title and related names in document view' do
      get '/catalog/5906024.json'
      r = JSON.parse(response.body)['response']['document']
      title_vern = r['title_vern_display']
      related = r['contains_display'][0]
      related_vern = r['contains_display'][1]
      get '/catalog/5906024'
      expect(response.body.include?("<h1 dir=\"rtl\"> #{title_vern} </h1>")).to eq true
      expect(response.body.include?("<li dir=\"ltr\"> #{related} </li>")).to eq true
      expect(response.body.include?("<li dir=\"rtl\"> #{related_vern} </li>")).to eq true
    end
  end

  describe 'left-anchor tests' do
    it 'finds result despite accents and capitals in query' do
      get '/catalog.json?&search_field=left_anchor&q=s%C3%A8arChing+for'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].any? { |d| d['id'] == '6574987' }).to eq true
    end

    it "no matches if it doesn't occur at the beginning of the starts with fields" do
      get '/catalog.json?&search_field=left_anchor&q=modern+aesthetic'
      r = JSON.parse(response.body)
      expect(r['response']['pages']['total_count']).to eq 0
    end

    it 'works in advanced search' do
      get '/catalog.json?&search_field=advanced&f1=left_anchor&q1=searching+for&op2=AND&f2=left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].any? { |d| d['id'] == '6574987' }).to eq true
    end
  end

  describe 'advanced search tests' do
    it 'supports advanced render constraints' do
      get '/catalog?&search_field=advanced&f1=left_anchor&q1=searching+for1&op2=AND&f2='\
          'left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for'
      expect(response.body.include?('<a class="btn btn-default remove dropdown-toggle" '\
                                    'href="/catalog?action=index&amp;controller=catalog&amp;'\
                                    'f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3='\
                                    'AND&amp;q2=searching+for&amp;q3=searching+for&amp;'\
                                    'search_field=advanced"><span class="glyphicon '\
                                    'glyphicon-remove"></span><span class="sr-only">Remove '\
                                    'constraint Title starts with: searching for1</span></a>')
            ).to eq true
      get '/catalog.json?&search_field=advanced&f1=left_anchor&q1=searching+for1&op2=AND&f2='\
          'left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].any? { |d| d['id'] == '6574987' }).to eq false
      get '/catalog?f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=advanced'
      expect(response.body.include?('<a class="btn btn-default remove dropdown-toggle" '\
                                    'href="/catalog?action=index&amp;controller=catalog&amp;'\
                                    'f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3='\
                                    'AND&amp;q2=searching+for&amp;q3=searching+for&amp;'\
                                    'search_field=advanced"><span class="glyphicon '\
                                    'glyphicon-remove"></span><span class="sr-only">'\
                                    'Remove constraint Starts with: searching for1</span></a>')
            ).to eq false
      get '/catalog.json?f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=advanced'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].any? { |d| d['id'] == '6574987' }).to eq true
    end
  end

  describe 'librarian view' do
    it 'marcxml matches bibdata marcxml for record' do
      id = '6574987'
      get "/catalog/#{id}.marcxml"
      librarian_view = response.body
      bibdata = Faraday.get("https://bibdata.princeton.edu/bibliographic/#{id}").body
      expect(librarian_view).to eq bibdata
    end
  end

  describe 'classic catalog link' do
    it 'is accessible from record show view' do
      id = '6574987'
      get "/catalog/#{id}"
      expect(response.body).to include voyager_url(id)
    end
    it 'is not accessible for non-Voyager records' do
      allow_any_instance_of(Blacklight::Solr::Document::Marc).to receive(:voyager_record?).and_return(false)
      id = '6574987'
      get "/catalog/#{id}"
      expect(response.body).not_to include voyager_url(id)
    end
  end

  describe 'identifier metadata' do
    it 'is accessible from show view' do
      id = '7916044'
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

  describe 'homepage facets' do
    it 'Only facets configured for homepage display are requested in Solr' do
      get '/catalog.json'
      r = JSON.parse(response.body)
      expect(r['response']['facets'].any? { |f| f['name'] == 'location' }).to eq true
      expect(r['response']['facets'].any? { |f| f['name'] == 'instrumentation_facet' }).to eq false
    end

    it 'All configured facets are requested in Solr within a search' do
      get '/catalog.json?search_field=all_fields'
      r = JSON.parse(response.body)
      expect(r['response']['facets'].any? { |f| f['name'] == 'location' }).to eq true
      expect(r['response']['facets'].any? { |f| f['name'] == 'instrumentation_facet' }).to eq true
    end
  end

  describe 'facets in search results' do
    it 'are configured with a tooltip for removing the book format facet parameter' do
      get '/?f%5Bformat%5D%5B%5D=Book&q=&search_field=all_fields'
      expect(response.body.include?('<span class="glyphicon glyphicon-remove" data-toggle="tooltip" data-original-title="Remove"></span>')).to eq true
      get '/?q=&search_field=all_fields'
      expect(response.body.include?('<span class="glyphicon glyphicon-remove" data-toggle="tooltip" data-original-title="Remove"></span>')).to eq false
    end
  end

  describe 'other versions' do
    it 'provides links to other versions of record when they are found' do
      get '/catalog/8553130'
      expect(response.body).not_to include('href="http://www.example.com/catalog/8553130"')
      expect(response.body).to include('href="http://www.example.com/catalog/9026021"')
      expect(response.body).to include('href="http://www.example.com/catalog/5291883"')
      get '/catalog/9026021'
      expect(response.body).not_to include('href="http://www.example.com/catalog/9026021"')
      expect(response.body).to include('href="http://www.example.com/catalog/8553130"')
      expect(response.body).to include('href="http://www.example.com/catalog/5291883"')
    end
    it 'provides link to linked related record (774 bib link) when found' do
      get '/catalog/4705304'
      expect(response.body).to include('href="http://www.example.com/catalog/4705307"')
    end
    it 'provides link to record in which current record is contained (773 bib link) when found' do
      get '/catalog/4705307'
      expect(response.body).to include('href="http://www.example.com/catalog/4705304"')
    end
    it 'provides link to other version of the record when linked via bib id in 776/787' do
      get '/catalog/3478898'
      expect(response.body).to include('href="http://www.example.com/catalog/3861539"')
    end
    it 'does not provide link to bib id in 776/787 if linked record does not exist' do
      get '/catalog/857469.json'
      linked_bib = '4478078'
      r = JSON.parse(response.body)
      expect(r['response']['document']['other_version_s']).to include("BIB#{linked_bib}")
      get '/catalog/857469'
      expect(response.body).not_to include("href=\"http://www.example.com/catalog/#{linked_bib}\"")
    end
  end

  describe 'standard no search' do
    it 'resolves to record represented by standard number' do
      get '/catalog/issn/0082-9455'
      expect(response).to redirect_to('/catalog/491654')
      get '/catalog/isbn/9781303457036'
      expect(response).to redirect_to('/catalog/7916044')
      get '/catalog/oclc/650437639'
      expect(response).to redirect_to('/catalog/6139836')
      get '/catalog/lccn/2007018609'
      expect(response).to redirect_to('/catalog/5291883')
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
end
