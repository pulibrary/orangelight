require 'rails_helper'

RSpec.describe 'Orangelight Browsables', type: :request do
  describe 'Redirect Tests for Browse' do
    it 'browse_name redirects to browse search' do
      get '/catalog?search_field=browse_name&q=velez'
      expect(response).to redirect_to '/browse/names?search_field=browse_name&q=velez'
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
  end

  describe 'Selected search box field' do
    it 'Based on search_field parameter when provided' do
      get '/catalog?q=&search_field=title'
      expect(response.body).to include('selected="selected" value="title">Title (keyword)</option>')
    end

    it 'Author (browse) is selected by default when browsing by name' do
      get '/browse/names?start=25'
      expect(response.body).to include('selected="selected" value="browse_name">Author (browse)</option>')
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
