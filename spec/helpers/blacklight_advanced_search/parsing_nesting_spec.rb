# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightAdvancedSearch::ParsingNestingParser do
  describe '#process_query' do
    subject(:queries) { process_query(_params, config) }

    let(:_params) { instance_double(ActiveSupport::HashWithIndifferentAccess) }
    let(:config) { Class.new }
    let(:advanced_search) { instance_double(Blacklight::OpenStructWithHashAccess) }
    let(:keyword_queries) do
      {
        'title' => 'anything',
        'all_fields' => '(something) OR (anything)'
      }
    end

    before do
      allow(config).to receive(:advanced_search).and_return(advanced_search)
      allow(config).to receive(:search_fields).and_return(keyword_queries)
      allow(self).to receive(:local_param_hash).with('all_fields', config).and_return({})
      allow(self).to receive(:local_param_hash).with('title', config).and_return("spellcheck.dictionary": 'title', qf: '$title_qf', pf: '$title_pf')
      allow(self).to receive(:keyword_op).and_return([])
      allow(self).to receive(:keyword_queries).and_return(keyword_queries)
    end

    it 'appends the operators to the queries' do
      allow(advanced_search).to receive(:[]).with(:query_parser).and_return('edismax')
      expect(queries).to include('_query_:"{!edismax spellcheck.dictionary=title qf=$title_qf pf=$title_pf}anything"  _query_:"{!dismax mm=1}something anything"')
    end

    context 'when the query parser is not specified in the advanced search' do
      let(:advanced_search) { nil }

      before do
        allow(Blacklight.logger).to receive(:error)
      end

      it 'logs an error and returns an empty query' do
        expect(queries).to be_empty
        expect(Blacklight.logger).to have_received(:error).with(/Failed to parse the advanced search, config\. settings are not accessible for\:/)
      end
    end

    context 'there are invalid keyword queries' do
      let(:keyword_queries) do
        {
          'title' => '(Yu pu za shuo) AND ("")',
          'all_fields' => '(something) OR (anything)'
        }
      end

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it 'parses only the valid queries and logs a warning' do
        allow(advanced_search).to receive(:[]).with(:query_parser).and_return('edismax')
        expect(queries).to eq '_query_:"{!dismax mm=1}something anything" '
        expect(Rails.logger).to have_received(:warn).with('Failed to parse the query: (Yu pu za shuo) AND (""): Extra input after last repetition at line 1 char 21.')
      end
    end
  end
end
