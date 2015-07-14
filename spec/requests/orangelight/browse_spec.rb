require 'rails_helper'


RSpec.describe "Orangelight Browsables", :type => :request do
	before(:all) do
		system "rake db:seed"	
	end
  
	describe "Redirect Tests for Browse" do
		it "browse_name redirects to browse search" do
			get "/catalog?search_field=browse_name&q=velez"
			expect(response).to redirect_to "/browse/names?search_field=browse_name&q=velez"
		end
		it "browse_subject redirects to browse search" do
			get "/catalog?search_field=browse_subject&q=art+patron"
			expect(response).to redirect_to "/browse/subjects?search_field=browse_subject&q=art+patron"
		end
		it "browse_cn redirects to browse search" do
			get "/catalog?search_field=browse_cn&q=MICROFILM"
			expect(response).to redirect_to "/browse/call_numbers?search_field=browse_cn&q=MICROFILM"
		end				
	end

  describe "Paging Functionality" do
    it "per page value can be set" do
    	get "/browse/subjects.json?rpp=25"
    	r = JSON.parse(response.body)
    	expect(r.length).to eq 25
    end
    it "start parameter sets which db entry to return first" do
    	get "/browse/subjects.json?start=7"
    	r = JSON.parse(response.body)
    	expect(r[0]["id"]).to eq 7
    end    

    it "shows last complete page if start param > db entries" do
    	get "/browse/subjects.json?rpp=10000"
  		r = JSON.parse(response.body)
  		subject_count = r.length
    	rpp = 10
    	get "/browse/subjects.json?start=9999&rpp=#{rpp}"
    	r = JSON.parse(response.body)
    	expect(r[0]["id"]).to eq subject_count-rpp+1
    end

    it "shows the first page if start param < 1" do
    	get "/browse/subjects.json?start=-2"
    	r = JSON.parse(response.body)
    	expect(r[0]["id"]).to eq 1    	
    end
  end

  describe "Browse Call Number Search" do
    it "includes non LC call numbers in search" do
      get '/browse/call_numbers.json?q=microfilm'
      r = JSON.parse(response.body)
      q_normalized = StringFunctions.cn_normalize('microfilm')
      expect(r[3]["sort"]..r[4]["sort"]).to cover q_normalized
    end
  end

  describe "Query Functionality" do
  	it "properly lowercases Russian characters"
  end

end


