# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::RequestHelper, type: :helper do
  describe '#request_title' do
    it 'returns a trace form title when mode is set' do
      assign(:mode, "trace") # instance variable
      expect(helper.request_title).to eq(I18n.t('requests.trace.form_title'))
    end

    it 'returns the default form title' do
      expect(helper.request_title).to eq(I18n.t('requests.default.form_title'))
    end
  end

  describe '#zero_results_link' do
    let(:test_strategy) { Flipflop::FeatureSet.current.test! }
    let(:query_params) { 'asdf' }
    let(:zero_results_link) { helper.zero_results_link(query_params, search_field) }

    context 'with old borrow direct provider' do
      before do
        test_strategy.switch!(:reshare_for_borrow_direct, false)
      end
      context 'with a standard keyword query' do
        let(:search_field) { 'all_fields' }

        it 'returns the link to borrow direct' do
          expect(zero_results_link).to eq('/borrow-direct?q=asdf')
        end
      end
      context 'with a title keyword query' do
        let(:search_field) { 'title' }

        it 'returns the link to borrow direct' do
          expect(zero_results_link).to eq('/borrow-direct?q=asdf')
        end
      end
    end
    context 'with new borrow direct provider' do
      before do
        test_strategy.switch!(:reshare_for_borrow_direct, true)
      end
      context 'with a standard keyword query' do
        let(:expected_url) { 'https://borrowdirect.reshare.indexdata.com/Search/Results?lookfor=asdf&type=AllFields' }
        let(:search_field) { 'all_fields' }

        it 'returns the link to borrow direct' do
          expect(zero_results_link).to eq(expected_url)
        end
      end
      context 'with a title keyword query' do
        let(:expected_url) { 'https://borrowdirect.reshare.indexdata.com/Search/Results?lookfor=asdf&type=Title' }
        let(:search_field) { 'title' }

        it 'returns the link to borrow direct' do
          expect(zero_results_link).to eq(expected_url)
        end
      end
      context 'with a subject keyword query' do
        let(:expected_url) { 'https://borrowdirect.reshare.indexdata.com/Search/Results?lookfor=asdf&type=Subject' }
        let(:search_field) { 'subject' }

        it 'returns the link to borrow direct' do
          expect(zero_results_link).to eq(expected_url)
        end
      end
      context 'with an author keyword query' do
        let(:expected_url) { 'https://borrowdirect.reshare.indexdata.com/Search/Results?lookfor=asdf&type=Author' }
        let(:search_field) { 'author' }

        it 'returns the link to borrow direct' do
          expect(zero_results_link).to eq(expected_url)
        end
      end
    end
  end
end
