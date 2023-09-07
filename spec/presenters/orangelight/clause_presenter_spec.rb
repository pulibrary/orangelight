# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::ClausePresenter do
  subject(:presenter) do
    described_class.new('0', params.with_indifferent_access.dig(:clause, '0'), field_config, nil, search_state)
  end

  let(:field_config) { Blacklight::Configuration::NullField.new key: 'some_field' }
  let(:search_state) { Blacklight::SearchState.new(params.with_indifferent_access, Blacklight::Configuration.new) }
  let(:params) { { clause: { '0' => { query: 'some search string', op: 'must_not' } } } }

  describe '#label' do
    it 'includes the NOT boolean operator if appropriate' do
      expect(subject.label).to eq 'NOT some search string'
    end
  end
end
