# frozen_string_literal: true

require 'rails_helper'

describe Requests::Illiad do
  let(:document) { SolrDocument.new(id: '9988805493506421', oclc_s: ['871228508']) }
  let(:ctx) { Requests::SolrOpenUrlContext.new(solr_doc: document).ctx }
  let(:illiad) { described_class.new(enum: "Volume foo", chron: "Chronicle 1") }

  it "provides an ILLiad URL" do
    expect(illiad.illiad_request_url(ctx)).to start_with(Requests::Config[:ill_base])
  end

  it 'includes the oclc number' do
    expect(illiad.illiad_request_url(ctx)).to include('rft.oclcnum=871228508')
    expect(illiad.illiad_request_url(ctx)).to include('rft_id=871228508')
  end

  it "provides illiad query parameters with enumeration" do
    expect(illiad.illiad_request_url(ctx)).to include(CGI.escape("Volume foo"))
  end
  context 'with a journal' do
    let(:document) { SolrDocument.new(id: '996262113506421', oclc_s: ['10708673'], format: ['Journal']) }

    it 'includes the oclc number' do
      expect(illiad.illiad_request_url(ctx)).to include('genre=serial')
      expect(illiad.illiad_request_url(ctx)).to include('rft.oclcnum=10708673')
      expect(illiad.illiad_request_url(ctx)).to include('rft_id=10708673')
    end
  end
end
