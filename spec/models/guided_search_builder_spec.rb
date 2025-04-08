require 'rails_helper'

describe GuidedSearchBuilder do
  let(:user_params) { Hash.new }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { double blacklight_config: blacklight_config }
  subject(:search_builder) { described_class.new scope }

  describe "booleans in edismax" do
    let(:blacklight_config) { CatalogController.blacklight_config.deep_copy }

    before do
      blacklight_config.search_fields.each_value do |val|
        val.clause_params = { edismax: val.solr_parameters.dup } if val.solr_parameters
      end
    end
    let(:user_params) do 
      { 
        clause: { 
          '0': { field: 'all_fields', query: 'apple', op: 'should' }, 
          '1': { field: 'title', query: 'banana', op: 'should' }
        }
      }
    end

    # clause = {"field" => "all_fields", "query" => "apple", "op" => "should"}
    # clause = {"field" => "title", "query" => "banana", "op" => "should"}
    subject(:query_parameters) do
      search_builder.with(user_params).processed_parameters
    end
  
    it "does not put them in the Solr bool clause" do
      expect(query_parameters.keys).to include('json')
      expect(query_parameters['json'].keys).to match_array(['query'])
      expect(query_parameters['json']['query'].keys).not_to include('bool')
    end
  end
end
