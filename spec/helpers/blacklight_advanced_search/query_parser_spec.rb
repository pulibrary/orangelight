# frozen_string_literal: true

require 'rails_helper'

describe BlacklightAdvancedSearch::QueryParser do
  describe '#keyword_queries' do
    subject(:query_parser) { described_class.new(params, config) }

    let(:blacklight_config) { Blacklight::Configuration.new }
    let(:params) do
      {
        'utf8' => '✓',
        'f1' => 'title',
        'q1' => 'Yu pu za shuo',
        'op2' => 'AND',
        'f2' => 'title',
        'q2' => '""',
        'op3' => 'AND',
        'f3' => 'title',
        'q3' => '',
        'range' => {
          'pub_date_start_sort' => {
            'begin' => '',
            'end' => ''
          }
        },
        'sort' => 'score desc, pub_date_start_sort desc, title_sort asc',
        'search_field' => 'advanced',
        'commit' => 'Search',
        'controller' => 'errors',
        'action' => 'error'
      }
    end

    it 'generates the keyword queries' do
      expect(query_parser.keyword_queries).to be_a Hash
      expect(query_parser.keyword_queries).to include('title' => '(Yu pu za shuo) AND ("")')
    end
  end
end
