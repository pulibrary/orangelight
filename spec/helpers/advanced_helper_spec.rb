# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvancedHelper do
  describe '#guided_field' do
    context 'when field_num is :clause_0_field' do
      it 'can get the field name from params clause[0][field]' do
        params[:clause] = { '0' => { 'field' => 'title' } }
        expect(guided_field(:clause_0_field, 'all_fields')).to eq('title')
      end
    end
  end

  describe '#label_tag_default_for' do
    context 'when key is :q1' do
      it 'takes search term from q param' do
        params['q'] = 'cats'
        params['search_field'] = 'all_fields'
        blacklight_config = Blacklight::Configuration.new do |config|
          config.add_search_field 'all_fields'
        end
        allow_any_instance_of(described_class).to receive(:blacklight_config).and_return(blacklight_config)
        expect(label_tag_default_for(:q1)).to eq('cats')
      end
    end
    context 'when key is :clause_0_query' do
      it 'takes search term from q param' do
        params['q'] = 'cats'
        params['search_field'] = 'all_fields'
        blacklight_config = Blacklight::Configuration.new do |config|
          config.add_search_field 'all_fields'
        end
        allow_any_instance_of(described_class).to receive(:blacklight_config).and_return(blacklight_config)
        expect(label_tag_default_for(:clause_0_query)).to eq('cats')
      end
      it 'takes search term from q param' do
        params[:clause] = { '0' => { 'field' => 'all_fields', 'query' => 'beasts' } }
        blacklight_config = Blacklight::Configuration.new do |config|
          config.add_search_field 'all_fields'
        end
        allow_any_instance_of(described_class).to receive(:blacklight_config).and_return(blacklight_config)
        expect(label_tag_default_for(:clause_0_query)).to eq('beasts')
      end
    end
  end
end
