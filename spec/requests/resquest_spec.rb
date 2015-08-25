require "rails_helper"
require "faraday"
include ApplicationHelper

describe "blacklight tests" do

  describe "ICU folding keyword search" do
    it "finds an Arabic entry from a Romanized search term" do
      get "/catalog.json?&search_field=all_fields&q=dawwani"
        r = JSON.parse(response.body)
        expect(r["response"]["docs"].any? {|d| d["id"] == "4705304"}).to eq true
    end
  end

  describe "Multiple locations check" do
    it "items with 3 or more holdings are listed as multiple holdings in search results" do
      get "/catalog/1984221.json"
      r = JSON.parse(response.body)
      expect(r["response"]["document"]["location"].length).to eq 3
        get "/catalog?&search_field=all_fields&q=1984221"
        expect(response.body.include?('<li class="blacklight-call_number_display" dir="ltr">Multiple Holdings</li>')).to eq true
    end
    it "displays the location name for an item with a single location" do
      get "/catalog/321.json"
      r = JSON.parse(response.body)
      expect(r["response"]["document"]["location"].length).to eq 1
      location = r["response"]["document"]["location"][0]
      get "/catalog?&search_field=all_fields&q=321"
      expect(response.body.include?("#{location}")).to eq true
    end
  end

  describe "Urlify check" do
    it "Links to an electronic resource with the appropriate display text" do
      get "/catalog/3.json"
      r = JSON.parse(response.body)
      link = r["response"]["document"]["electronic_access_display"][0]
      display_text = r["response"]["document"]["electronic_access_display"][1]
      get "/catalog/3"
      expect(response.body.include?("<a target=\"_blank\" href=\"#{link}\">#{display_text}</a>")).to eq true
    end

    it "uses hyperlink as display text" do
      get "/catalog/4705304.json"
      r = JSON.parse(response.body)
      link = r["response"]["document"]["electronic_access_display"][0]
        display_text = r["response"]["document"]["electronic_access_display"][0]
      get "/catalog/4705304"
      expect(response.body.include?("<a target=\"_blank\" href=\"#{link}\">#{display_text}</a>")).to eq true
    end
  end

  describe "Wheretofind check" do
    it "provides a link to locate an item for each holding" do
      get "/catalog/430472.json"
      r = JSON.parse(response.body)
      docid = r["response"]["document"]["id"]
      get "/catalog/430472"
      r["response"]["document"]["location_code_s"].each do |location|
        expect(response.body.include?("target=\"_blank\" class=\"find-it\" href=\"http://library.princeton.edu/searchit/map?loc=#{location}&amp;id=#{docid}\">[Find it]</a>")).to eq true
      end
    end
  end

  SEPARATOR = "—"
  describe "subjectify check" do
    it "provides links to facet search based on hierarchy" do
      get "/catalog/6139836.json"
      r = JSON.parse(response.body)
      sub_component = []
      fullsubject = r["response"]["document"]["subject_display"]
      fullsubject.each_with_index do |subject, i|
        sub_component << subject.split(SEPARATOR)
      end
      get "/catalog/6139836"
      fullsubject.each_with_index do |subject, i|
        sub_component[i].each do |component|
          c = Regexp.escape(component)
          expect(response.body.include?("class=\"search-subject\" data-toggle=\"tooltip\" data-original-title=\"Search: #{subject[/.*#{c}/]}\" title=\"Search: #{subject[/.*#{c}/]}\" href=\"/?f[subject_topic_facet][]=#{subject[/.*#{c}/]}\">#{component}</a>")).to eq true
        end
      end
    end
  end

  describe "dir tag check" do

    it "adds rtl dir for title and author field in search results" do
      get "/catalog.json?&search_field=all_fields&q=4705304"
      r = JSON.parse(response.body)["response"]["docs"].select{|d| d["id"] == "4705304"}[0]
      title_vern = r["title_vern_display"]
      author = r["author_display"][0]
      author_vern = r["author_display"][1]
      doc_id = r["id"]
      get "/catalog?&search_field=all_fields&q=4705304"
      expect(response.body.include?("dir=\"rtl\" style=\"float: right;\" href=\"/catalog/#{doc_id}\">#{title_vern}</a>")).to eq true
      expect(response.body.include?("<li dir=\"ltr\"> <a class=\"search-name\" data-toggle=\"tooltip\" data-original-title=\"Search: #{author}\" title=\"Search: #{author}\" href=\"/?f[author_s][]=#{author}\">#{author}</a>")).to eq true
      expect(response.body.include?("<li dir=\"rtl\"> <a class=\"search-name\" data-toggle=\"tooltip\" data-original-title=\"Search: #{author_vern}\" title=\"Search: #{author_vern}\" href=\"/?f[author_s][]=#{author_vern}\">#{author_vern}</a>")).to eq true

    end
    it "adds ltr rtl dir for title and related names in document view" do
      get "/catalog/5906024.json"
      r = JSON.parse(response.body)["response"]["document"]
      title_vern = r["title_vern_display"]
      related = r["contains_display"][0]
      related_vern = r["contains_display"][1]
      get "/catalog/5906024"
      expect(response.body.include?("<h1 dir=\"rtl\"> #{title_vern} </h1>")).to eq true
      expect(response.body.include?("<li dir=\"ltr\"> #{related} </li>")).to eq true
      expect(response.body.include?("<li dir=\"rtl\"> #{related_vern} </li>")).to eq true
    end
  end

  describe "left-anchor tests" do
    it "finds result despite accents and capitals in query" do
      get "/catalog.json?&search_field=left_anchor&q=s%C3%A8arChing+for"
      r = JSON.parse(response.body)
      expect(r["response"]["docs"].any? {|d| d["id"] == "6574987"}).to eq true
    end

    it "no matches if it doesn't occur at the beginning of the starts with fields" do
      get "/catalog.json?&search_field=left_anchor&q=modern+aesthetic"
      r = JSON.parse(response.body)
      expect(r["response"]["pages"]["total_count"]).to eq 0
    end

    it "works in advanced search" do
      get "/catalog.json?&search_field=advanced&left_anchor=searching+for"
      r = JSON.parse(response.body)
      expect(r["response"]["docs"].any? {|d| d["id"] == "6574987"}).to eq true
    end
    it "works in guided search" do
      get "/catalog.json?&search_field=guided&f1=left_anchor&q1=searching+for&op2=AND&f2=left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for"
      r = JSON.parse(response.body)
      expect(r["response"]["docs"].any? {|d| d["id"] == "6574987"}).to eq true
    end
  end

  describe "advanced search tests" do
    it "supports guided render constraints" do
      get "/catalog?&search_field=guided&f1=left_anchor&q1=searching+for1&op2=AND&f2=left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for"
      expect(response.body.include?('<a class="btn btn-default remove dropdown-toggle" href="/catalog?action=index&amp;controller=catalog&amp;f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=guided"><span class="glyphicon glyphicon-remove"></span><span class="sr-only">Remove constraint Starts with: searching for1</span></a>')).to eq true
      get "/catalog.json?&search_field=guided&f1=left_anchor&q1=searching+for1&op2=AND&f2=left_anchor&q2=searching+for&op3=AND&f3=left_anchor&q3=searching+for"
      r = JSON.parse(response.body)
      expect(r["response"]["docs"].any? {|d| d["id"] == "6574987"}).to eq false
      get "/catalog?f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=guided"
      expect(response.body.include?('<a class="btn btn-default remove dropdown-toggle" href="/catalog?action=index&amp;controller=catalog&amp;f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=guided"><span class="glyphicon glyphicon-remove"></span><span class="sr-only">Remove constraint Starts with: searching for1</span></a>')).to eq false
      get "/catalog.json?f2=left_anchor&amp;f3=left_anchor&amp;op2=AND&amp;op3=AND&amp;q2=searching+for&amp;q3=searching+for&amp;search_field=guided"
      r = JSON.parse(response.body)
      expect(r["response"]["docs"].any? {|d| d["id"] == "6574987"}).to eq true
    end
  end

  describe "librarian view" do
    it "marcxml matches bibdata marcxml for record" do
      id = '6574987'
      get "/catalog/#{id}.marcxml"
      librarian_view = response.body
      bibdata = Faraday.get("http://bibdata.princeton.edu/bibliographic/#{id}").body
      expect(librarian_view).to eq bibdata
    end
  end

  describe "classic catalog link" do
    it "is accessible from record show view" do
      id = '6574987'
      get "/catalog/#{id}"
      expect(response.body).to include voyager_url(id)
    end
  end

  describe "homepage facets" do
    it "Only facets configured for homepage display are requested in Solr" do
      get "/catalog.json"
      r = JSON.parse(response.body)
      expect(r["response"]["facets"].any? {|f| f['name'] == 'access_facet'}).to eq true
      expect(r["response"]["facets"].any? {|f| f['name'] == 'instrumentation_facet'}).to eq false
    end

    it "All configured facets are requested in Solr within a search" do
      get "/catalog.json?search_field=all_fields"
      r = JSON.parse(response.body)
      expect(r["response"]["facets"].any? {|f| f['name'] == 'access_facet'}).to eq true
      expect(r["response"]["facets"].any? {|f| f['name'] == 'instrumentation_facet'}).to eq true
    end
  end

  describe "facets in search results" do
    it "are configured with a tooltip for removing the book format facet parameter" do
      get "/?f%5Bformat%5D%5B%5D=Book&q=&search_field=all_fields"
      expect(response.body.include?('<span class="glyphicon glyphicon-remove" data-toggle="tooltip" data-original-title="Remove"></span>')).to eq true
      get "/?q=&search_field=all_fields"
      expect(response.body.include?('<span class="glyphicon glyphicon-remove" data-toggle="tooltip" data-original-title="Remove"></span>')).to eq false      
    end
  end
end
