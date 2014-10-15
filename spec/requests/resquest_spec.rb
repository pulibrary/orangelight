require "rails_helper"

describe "blacklight tests" do

	before(:all) do
		fixture=File.expand_path('../../fixtures/fixtures1014.xml',__FILE__)  	
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
	    expect(response.body.include?('<dd class="blacklight-location" dir="ltr">Multiple Locations</dd>')).to eq true
		end
		it "displays the location name for an item with a single location" do
			get "/catalog.json?&search_field=all_fields&q="
			r = JSON.parse(response.body)
			expect(r["response"]["docs"].select{|d| d["id"] == "321"}[0]["location"].length).to eq 1
	    location = r["response"]["docs"].select{|d| d["id"] == "321"}[0]["location"][0]
	    get "/catalog?&search_field=all_fields&q=accessions"
	    expect(response.body.include?("<dd class=\"blacklight-location\" dir=\"ltr\">#{location}</dd>")).to eq true
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
					expect(response.body.include?("/?f[subject_topic_facet][]=#{subject[/.*#{c}/]}&amp;q=&amp;search_field=all_fields\">#{component}</a>")).to eq true
				end
	    end
		end
	end	

	describe "dir tag check" do

		it "adds rtl dir for title and author field in search results" do
			get "/catalog.json?&search_field=all_fields&q=4705304"
			r = JSON.parse(response.body)["response"]["docs"].select{|d| d["id"] == "4705304"}[0]
			title_vern = r["title_vern_display"]
			author = r["author_s"][0]
			author_vern = r["author_s"][1]
			doc_id = r["id"]		
			get "/catalog?&search_field=all_fields&q=4705304"			
			expect(response.body.include?("dir=\"rtl\" href=\"/catalog/#{doc_id}\" style=\"float: right;\">#{title_vern}</a>")).to eq true
			expect(response.body.include?("<li dir=\"ltr\"> <a href=\"/?f%5Bauthor_s%5D%5B%5D=#{CGI.escape author}\">#{author}</a> </li>")).to eq true
			expect(response.body.include?("<li dir=\"rtl\"> <a href=\"/?f%5Bauthor_s%5D%5B%5D=#{CGI.escape author_vern}\">#{author_vern}</a> </li>")).to eq true

		end
		it "adds ltr rtl dir for title and related names in document view" do
			get "catalog/5906024.json"		
			r = JSON.parse(response.body)["response"]["document"]
			title_vern = r["title_vern_display"]
			related = r["related_name_display"][0]
			related_vern = r["related_name_display"][1]
			get "catalog/5906024"
			expect(response.body.include?("<h3 dir=\"rtl\"> #{title_vern} </h3>")).to eq true	
			expect(response.body.include?("<li dir=\"ltr\"> #{related} </li>")).to eq true
			expect(response.body.include?("<li dir=\"rtl\"> #{related_vern} </li>")).to eq true					
		end
	end

end
