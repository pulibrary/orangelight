# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "left anchor search", left_anchor: true do
  it 'finds result despite accents and capitals in query' do
    get '/catalog.json?&search_field=left_anchor&q=s%C3%A8arChing+for'
    r = JSON.parse(response.body)
    expect(r['data'].any? { |d| d['id'] == '9965749873506421' }).to eq true
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
    get '/catalog.json?clause[0][field]=left_anchor&clause[0][query]=searching+for&clause[1][op]=must&clause[1][field]=left_anchor&clause[1][query]=searching+for&clause[2][op]=must&clause[2][field]=left_anchor&clause[2][query]=searching+for'
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
      get '/catalog.json?clause[0][field]=left_anchor&clause[0][query]=JSTOR*'
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
      get "/catalog.json?clause[0][field]=left_anchor&clause[0][query]=#{CGI.escape('浄名玄論 / 京都国立博物館編 ; 解說石塚晴道 (北海道大学名誉教授)')}&search_field=advanced"
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9981818493506421' }).to eq true
    end
  end
  it 'supports advanced render constraints' do
    stub_holding_locations
    get '/catalog?clause[0][field]=left_anchor&clause[0][query]=plasticity&clause[1][op]=must&clause[1][field]=author&clause[1][query]=&clause[2][op]=must&clause[2][field]=title&clause[2][query]=&range[pub_date_start_sort][begin]=&range[pub_date_start_sort][end]=&commit=Search'
    expect(response.body).to include 'Remove constraint Title starts with: plasticity'
    get '/catalog.json?clause[0][field]=left_anchor&clause[0][query]=plasticity&clause[1][op]=must&clause[1][field]=author&clause[1][query]=&clause[2][op]=must&clause[2][field]=title&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&search_field=advanced&commit=Search'
    r = JSON.parse(response.body)
    expect(r['data'].any? { |d| d['id'] == '99125535710106421' }).to eq true
    get '/catalog?search_field=advanced&clause[0][field]=left_anchor&clause[1][field]=author&clause[2][field]=title&clause[1][op]=must_not&clause[2][op]=must&clause[0][query]=plasticity&clause[1][query]=&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&clause[0][field]=all_fields&clause[0][query]=&clause[1][op]=must_not&clause[1][field]=left_anchor&clause[1][query]=plasticity&clause[2][op]=must&clause[2][field]=title&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&search_field=advanced&commit=Search'
    expect(response.body).not_to include 'Remove constraint Title starts with: plasticity'
    get '/catalog.json?search_field=advanced&clause[0][field]=left_anchor&clause[1][field]=author&clause[2][field]=title&clause[1][op]=must_not&clause[2][op]=must&clause[0][query]=plasticity&clause[1][query]=&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&clause[0][field]=all_fields&clause[0][query]=&clause[1][op]=must_not&clause[1][field]=left_anchor&clause[1][query]=plasticity&clause[2][op]=must&clause[2][field]=title&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D=&range%5Bpub_date_start_sort%5D%5Bend%5D=&search_field=advanced&commit=Search'
    r = JSON.parse(response.body)
    expect(r['data'].any? { |d| d['id'] == '99125535710106421' }).to eq false
  end
  it 'title starts with can be ORed across several 3 queries', left_anchor: true do
    get '/catalog.json?clause[0][field]=left_anchor&clause[0][query]=Reconstructing+the&clause[1][op]=should&clause[1][field]=left_anchor&clause[1][query]='\
        'This+angel+on&clause[2][op]=should&clause[2][field]=left_anchor&clause[2][query]=Almost+Human&search_field=advanced&commit=Search'
    r = JSON.parse(response.body)
    doc_ids = %w[9992220243506421 9222024 dsp01ft848s955 dsp017s75dc44p]
    expect(r['data'].all? { |d| doc_ids.include?(d['id']) }).to eq true
  end
  context 'with punctuation marks in the title' do
    it 'handles whitespace characters padding punctuation in the left_anchor field', left_anchor: true do
      get '/catalog.json?clause[0][field]=left_anchor&clause[0][query]=JSTOR+%5Belectronic+resource%5D+%3A&op2='\
          'AND&clause[1][field]=author&clause[1][query]=&clause[2][op]=must&clause[2][field]=title&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D='\
          '&range%5Bpub_date_start_sort%5D%5Bend%5D=&sort=score+desc%2C+pub_date_start_sort'\
          '+desc%2C+title_sort+asc&search_field=advanced&commit=Search'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true

      get '/catalog.json?clause[0][field]=left_anchor&clause[0][query]=JSTOR+%5Belectronic+resource%5D%3A&op2='\
          'AND&clause[1][field]=author&clause[1][query]=&clause[2][op]=must&clause[2][field]=title&clause[2][query]=&range%5Bpub_date_start_sort%5D%5Bbegin%5D='\
          '&range%5Bpub_date_start_sort%5D%5Bend%5D=&sort=score+desc%2C+pub_date_start_sort'\
          '+desc%2C+title_sort+asc&search_field=advanced&commit=Search'
      r = JSON.parse(response.body)
      expect(r['data'].any? { |d| d['id'] == '9928379683506421' }).to eq true
    end
  end
end
