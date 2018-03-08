# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'course reserves' do
  before do
    conn = Blacklight.default_index.connection
    conn.delete_by_query('type_s:ReserveListing')
    conn.commit
  end
  describe 'searching with an instructor name given' do
    it 'returns matching reserve ids' do
      stub_all_query
      stub_bib_ids
      get '/catalog.json?search_field=all_fields&f[instructor][]=Test, Jane&f[filter][]=Course Reserves'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].length).to eq 2
      get '/catalog.json?search_field=all_fields&f[instructor][]=Test, Joe&f[filter][]=Course Reserves'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].length).to eq 1
    end
  end

  describe 'searching with a department given' do
    it 'returns matching reserve ids' do
      stub_all_query
      stub_bib_ids
      get '/catalog.json?search_field=all_fields&f[department][]=MOL: Molecular Biology&f[filter][]=Course Reserves'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].length).to eq 3
    end
  end

  describe 'searching with both an instructor and course' do
    it 'returns only those matching both result sets' do
      stub_all_query
      stub_bib_ids
      get '/catalog.json?search_field=all_fields&f[instructor][]=Test, Jane&f[filter][]=Course Reserves'
      get '/catalog.json?search_field=all_fields&f[instructor][]=Test, Jane&f[course][]=MOL 343: Genetics&f[filter][]=Course Reserves'
      # Ensure non-matching documents aren't deleted.
      expect(Blacklight.default_index.connection.get('select', params: { q: 'type_s:ReserveListing AND instructor_s:"Test, Jane"' })['response']['docs'].length).to eq 2
      r = JSON.parse(response.body)
      expect(r['response']['docs'].length).to eq 1
    end
  end

  describe 'course_reserve_filters' do
    it 'builds array from solr_parameters[:fq] and traps nil if first part cannot split \'=\' ' do
      stub_all_query
      stub_bib_ids
      get '/catalog.json?search_field=all_fields&f[instructor][]=Himpele, J.&f[course][]=ANT 454: Transcultural Cinema&f[recently_added_facet][]=months_2&f[filter][]=Course Reserves'
      r = JSON.parse(response.body)
      expect(r['response']['docs'].length).to eq 1
    end
  end

  def stub_all_query
    stub_request(:get, "#{ENV['bibdata_base']}/courses")
      .to_return(status: 200,
                 body: all_results.to_json)
  end

  def stub_bib_ids
    stub_1
    stub_2
    stub_3
    stub_4
    stub_5
  end

  def stub_1
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=1958&reserve_id[]=2088")
      .to_return(status: 200,
                 body: (reserve_1 + reserve_3).to_json)
  end

  def stub_2
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=1958&reserve_id[]=2087&reserve_id[]=2088")
      .to_return(status: 200,
                 body: (reserve_1 + reserve_2 + reserve_3).to_json)
  end

  def stub_3
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=2087")
      .to_return(status: 200,
                 body: reserve_2.to_json)
  end

  def stub_4
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=2088")
      .to_return(status: 200,
                 body: reserve_3.to_json)
  end

  def stub_5
    stub_request(:get, "#{ENV['bibdata_base']}/bib_ids?reserve_id[]=9194")
      .to_return(status: 200,
                 body: reserve_4.to_json)
  end

  def reserve_1
    [
      {
        reserve_list_id: 1958,
        bib_id: 4_705_304
      }
    ]
  end

  def reserve_2
    [
      {
        reserve_list_id: 2087,
        bib_id: 430_472
      }
    ]
  end

  def reserve_3
    [
      {
        reserve_list_id: 2088,
        bib_id: 345_682
      }
    ]
  end

  def reserve_4
    [
      {
        reserve_list_id: 9194,
        bib_id: 10_628_252
      }
    ]
  end

  def all_results
    [
      {
        reserve_list_id: 1958,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'Genetics',
        course_number: 'MOL 342',
        section_id: 171,
        instructor_first_name: 'Jane',
        instructor_last_name: 'Test'
      },
      {
        reserve_list_id: 2088,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'Genetics',
        course_number: 'MOL 343',
        section_id: 171,
        instructor_first_name: 'Jane',
        instructor_last_name: 'Test'
      },
      {
        reserve_list_id: 2087,
        department_name: 'Molecular Biology',
        department_code: 'MOL',
        course_name: 'From DNA to Human Complexity',
        course_number: 'MOL 101',
        section_id: 0,
        instructor_first_name: 'Joe',
        instructor_last_name: 'Test'
      },
      {
        reserve_list_id: 9194,
        department_name: 'Anthropology',
        department_code: 'ANT',
        course_name: 'Transcultural Cinema',
        course_number: 'ANT 454',
        section_id: 0,
        instructor_first_name: 'J.',
        instructor_last_name: 'Himpele'
      }
    ]
  end
end
