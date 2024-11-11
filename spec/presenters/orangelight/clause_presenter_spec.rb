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
  describe '#field_label' do
    context 'when the field config does not exist' do
      let(:field_config) { nil }

      it 'returns nil' do
        expect(subject.field_label).to be_nil
      end

      it 'does not raise an error' do
        expect { subject.field_label }.not_to raise_error
      end
    end
  end
end
