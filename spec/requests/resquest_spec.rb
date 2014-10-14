require "rails_helper"

describe "blacklight tests" do

	before(:all) do
		fixture=File.expand_path('../../fixtures/fixtures1.xml',__FILE__)  	
	    system "curl http://localhost:8888/solr/blacklight-core/update?commit=true --data-binary @#{fixture} -H 'Content-type:text/xml; charset=utf-8'"

	end	
	describe "ICU folding keyword search" do

	  it "finds an Arabic entry from a Romanized search term" do
	    get "/catalog.json?&search_field=all_fields&q=dawwani"
	    r = JSON.parse(response.body)
	    expect(r["response"]["docs"].select{|d| d["id"] == "4705304"}.length).to eq 1 
	  end
	end

	describe "Multiple locations check" do
		it "indicates an item has multiple holdings locations" do
			get "/catalog.json?&search_field=all_fields&q="
	    r = JSON.parse(response.body)
	    expect(r["response"]["docs"].select{|d| d["id"] == "3"}[0]["location"].length).to eq 2
	    get "/catalog?&search_field=all_fields&q=guida"
	    expect(response.body.include?('<dd class="blacklight-location">Multiple Locations</dd>')).to eq true
		end
		it "displays the location name for an item with a single location" do
			get "/catalog.json?&search_field=all_fields&q="
	    r = JSON.parse(response.body)
	    expect(r["response"]["docs"].select{|d| d["id"] == "321"}[0]["location"].length).to eq 1
	    location = r["response"]["docs"].select{|d| d["id"] == "321"}[0]["location"][0]
	    get "/catalog?&search_field=all_fields&q=accessions"
	    expect(response.body.include?("<dd class=\"blacklight-location\">#{location}</dd>")).to eq true
		end
	end

	describe "Urlify check" do
		it "Links to an electronic resource with the appropriate display text" do
			get "/catalog/3.json"
	    r = JSON.parse(response.body)
	    link = r["response"]["document"]["electronic_access_display"][0]
	    display_text = r["response"]["document"]["electronic_access_display"][1]
			get "/catalog/3"
			expect(response.body.include?("<a href=\"#{link}\" target=\"_blank\">#{display_text}</a>")).to eq true
		end

		it "uses hyperlink as display text" do
			get "/catalog/4705304.json"
	    r = JSON.parse(response.body)
	    link = r["response"]["document"]["electronic_access_display"][0]
	    display_text = r["response"]["document"]["electronic_access_display"][0]
			get "/catalog/4705304"
			expect(response.body.include?("<a href=\"#{link}\" target=\"_blank\">#{display_text}</a>")).to eq true
		end
	end

	describe "Wheretofind check" do
		it "provides a link to locate an item for each holding" do
			get "catalog/430472.json"
	    r = JSON.parse(response.body)			
			docid = r["response"]["document"]["id"]
			get "catalog/430472"
			r["response"]["document"]["location_code_display"].each do |location|
				expect(response.body.include?("<a href=\"http://library.princeton.edu/searchit/map?loc=#{location}&amp;id=#{docid}\" target=\"_blank\">Locate</a>")).to eq true
			end
		end
	end

	SEPARATOR = "—"
	describe "subjectify check" do
		it "provides links to facet search based on hierarchy" do
			get "catalog/6139836.json"
	    r = JSON.parse(response.body)
	    sub_component = []
	    fullsubject = r["response"]["document"]["subject_display"]
	    fullsubject.each_with_index do |subject, i|
	    	sub_component << subject.split(SEPARATOR)
	    end
	    get "catalog/6139836"
	    fullsubject.each_with_index do |subject, i|
	    	sub_component[i].each do |component|
	    		c = Regexp.escape(component)
					expect(response.body.include?("?f[subject_topic_facet][]=#{subject[/.*#{c}/]}&amp;q=&amp;search_field=all_fields\">#{component}</a>")).to eq true
	    	end
	    end
		end
	end	

	describe "dir tag check" do
		it "adds rtl dir for title in search results" do
		end
		it "adds rtl dir for author field in search results" do
		end
		it "adds rtl dir for title in document view" do
		end
		it "adds rtl dir for author field in document view" do
		end						
	end

end