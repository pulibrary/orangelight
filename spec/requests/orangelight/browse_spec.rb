# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orangelight Browsables', type: :request do
  describe 'Redirect Tests for Browse' do
    it 'browse_name redirects to browse search' do
      get '/catalog?search_field=browse_name&q=velez'
      expect(response).to redirect_to '/browse/names?search_field=browse_name&q=velez'
    end
    it 'name_title redirects to browse search' do
      get '/catalog?search_field=name_title&q=murakami'
      expect(response).to redirect_to '/browse/name_titles?search_field=name_title&q=murakami'
    end
    it 'browse_subject redirects to browse search' do
      get '/catalog?search_field=browse_subject&q=art+patron'
      expect(response).to redirect_to '/browse/subjects?search_field=browse_subject&q=art+patron'
    end
    it 'browse_cn redirects to browse search' do
      get '/catalog?search_field=browse_cn&q=MICROFILM'
      expect(response).to redirect_to '/browse/call_numbers?search_field=browse_cn&q=MICROFILM'
    end
  end

  describe 'Paging Functionality' do
    it 'per page value can be set' do
      get '/browse/subjects.json?rpp=25'
      r = JSON.parse(response.body)
      expect(r.length).to eq 25
    end
    it 'start parameter sets which db entry to return first' do
      get '/browse/subjects.json?start=7'
      r = JSON.parse(response.body)
      expect(r[0]['id']).to eq 7
    end

    it 'shows last complete page if start param > db entries' do
      get '/browse/subjects.json?rpp=10000'
      r = JSON.parse(response.body)
      subject_count = r.length
      rpp = 10
      get "/browse/subjects.json?start=9999&rpp=#{rpp}"
      r = JSON.parse(response.body)
      expect(r[0]['id']).to eq subject_count - rpp + 1
    end

    it 'shows the first page if start param < 1' do
      get '/browse/subjects.json?start=-2'
      r = JSON.parse(response.body)
      expect(r[0]['id']).to eq 1
    end
  end

  describe 'Browse Call Number Search' do
    it 'escapes call number browse link urls' do
      get '/browse/call_numbers?q=Islamic+Manuscripts%2C+New+Series+no.+1948'
      expect(response.body).to include('/catalog/?f[call_number_browse_s][]=Islamic+Manuscripts%2C+New+Series+no.+1948')
    end
    it 'displays full publisher information' do
      get '/browse/call_numbers.json?q=QA303.2+.W45+2014'
      r = JSON.parse(response.body)
      expect(r[2]['date']).to include('Boston : Pearson, [2014]')
    end
    it 'displays pub_created_vern_display field' do
      get '/browse/call_numbers.json?q=BQ2215+.J59+2014'
      r = JSON.parse(response.body)
      expect(r[2]['date']).to eq '東京 : 勉誠出版, 2014.'
    end
    it 'displays author_s when author_display is not present' do
      get '/browse/call_numbers.json?q=48.1'
      r = JSON.parse(response.body)
      expect(r[2]['author']).to eq 'Gutenberg, Johann, 1397?-1468'
    end
  end

  describe 'Multiple locations/titles' do
    it 'formats multiple titles as n titles with this call number' do
      get '/browse/call_numbers.json?q=ac102&rpp=5'
      r = JSON.parse(response.body)
      expect(r[2]['title']).to match(/\d+ titles with this call number/)
    end
    it 'single title with multiple holdings in same location, display single location' do
      get '/browse/call_numbers.json?q=QA303.2+.W45+2014&rpp=5'
      r = JSON.parse(response.body)
      expect(r[2]['title']).to match(/Thomas' calculus : multivariable/)
      expect(r[2]['location']).not_to match(/Multiple locations/)
    end
    it 'single title with multiple locations' do
      get '/browse/call_numbers.json?q=RA643.86.B6+B54+2007&rpp=5'
      r = JSON.parse(response.body)
      expect(r[2]['title']).not_to match(/\d+ titles with this call number/)
      expect(r[2]['location']).to match(/Multiple locations/)
    end
  end

  describe 'Selected search box field' do
    it 'Based on search_field parameter when provided' do
      stub_holding_locations
      get '/catalog?q=&search_field=title'
      expect(response.body).to include('selected="selected" value="title">Title (keyword)</option>')
    end

    it 'Author (browse) is selected by default when browsing by name' do
      get '/browse/names?start=25'
      expect(response.body).to include('selected="selected" value="browse_name">Author (browse)</option>')
    end

    it 'Name (sorted by title) is selected by default when browsing by name title' do
      get '/browse/name_titles?start=5'
      expect(response.body).to include('<option data-placeholder="Last name, first name. Title" selected="selected" value="name_title">Author (sorted by title)</option>')
    end

    it 'Subject (browse) is selected by default when browsing by subject' do
      get '/browse/subjects?start=25'
      expect(response.body).to include('selected="selected" value="browse_subject">Subject (browse)</option>')
    end

    it 'Call number (browse) is selected by default when browsing by call number' do
      get '/browse/call_numbers?start=25'
      expect(response.body).to include('<option data-placeholder="e.g. P19.737.3" selected="selected" value="browse_cn">Call number (browse)</option>')
    end
  end
end
