# frozen_string_literal: true
require 'rails_helper'
require 'borrow_direct'

describe Requests::BorrowDirectLookup do
  let(:borrow_direct_lookup) { described_class.new }

  context 'An available item in borrow direct' do
    let(:good_params) do
      {
        isbn: '0415296633'
      }
    end

    let(:good_bd_response) do
      instance_double('bd_find_item')
    end

    describe '#find' do
      it 'Returns a good BorrowDirect::FindItem response' do
        expect(borrow_direct_lookup).to receive(:find).with(good_params).and_return(good_bd_response)
        expect(borrow_direct_lookup.find(good_params)).to eq(good_bd_response)
      end
    end

    describe '#available?' do
      it 'is available for request' do
        expect(borrow_direct_lookup).to receive(:find).with(good_params).and_return(good_bd_response)
        expect(borrow_direct_lookup.find(good_params)).to eq(good_bd_response)
        expect(borrow_direct_lookup).to receive(:available?).and_return(true)
        expect(borrow_direct_lookup.available?).to be true
      end
    end
  end

  context 'An unavailable item in borrow direct' do
    let(:bad_params) do
      {
        isbn: '121313131313'
      }
    end
    let(:bad_bd_response) do
      instance_double('bd_find_item')
    end
    let(:solr_doc) do
      {
        "id" => '12321323',
        'author_citation_display' => ['Student, Joe'],
        'title_citation_display' => ['A Test Title']
      }
    end
    let(:solr_doc_no_author) do
      {
        "id" => '12321323',
        'title_citation_display' => ['A Test Title']
      }
    end
    describe '#find' do
      it 'Returns a bad BorrowDirect::FindItem response' do
        expect(borrow_direct_lookup).to receive(:find).with(bad_params).and_return(bad_bd_response)
        expect(borrow_direct_lookup.find(bad_params)).to eq(bad_bd_response)
      end
    end

    describe '#available?' do
      it 'Is not available for request' do
        expect(borrow_direct_lookup).to receive(:find).with(bad_params).and_return(bad_bd_response)
        expect(borrow_direct_lookup.find(bad_params)).to eq(bad_bd_response)
        expect(borrow_direct_lookup).to receive(:available?).and_return(false)
        expect(borrow_direct_lookup.available?).to be false
      end
    end
  end
end
