# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::NonAlmaAeonUrl do
  let(:holdings) do
    { "thesis" => {} }
  end
  let(:document) do
    SolrDocument.new({
                       id: '9999999',
                       title_display: 'A book of poems',
                       form_genre_display: ['Poetry'],
                       author_display: ['Person 1', 'Person 2'],
                       holdings_1display: holdings.to_json.to_s
                     })
  end
  before do
    stub_holding_locations
  end
  subject { described_class.new(document:, holding: holdings).to_s }
  it 'uses Action 10' do
    expect(subject).to include('Action=10')
  end
  it 'uses form 21' do
    expect(subject).to include('Form=21')
  end
  it 'provides a title with the genre appended' do
    expect(subject).to include('ItemTitle=A+book+of+poems+%5B+Poetry+%5D')
  end
  it 'concatenates a list of authors from the author_display field' do
    expect(subject).to include('ItemAuthor=Person+1+AND+Person+2')
  end
  it 'defaults to the thesis genre' do
    expect(subject).to include('genre=thesis')
  end
  context 'when the holdings has a coin call number' do
    let(:holdings) do
      { "numismatics" => { "call_number": "Coin 11362" } }
    end
    it 'includes the numismatics genre' do
      expect(subject).to include('genre=numismatics')
    end
  end
end
