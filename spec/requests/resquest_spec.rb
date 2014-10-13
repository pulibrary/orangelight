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

	end
end