# frozen_string_literal: true

require 'rails_helper'

describe Requests::Illiad, vcr: { cassette_name: 'request_models', record: :none } do
  let(:params) do
    {
      system_id: '9988805493506421',
      mfhd: '22705318390006421',
      user: user
    }
  end
  let(:request_with_holding_item) { described_class.new(params) }

  let(:ctx) do
    document = SolrDocument.new(id: '9988805493506421')
    Requests::SolrOpenUrlContext.new(solr_doc: document).ctx
  end

  it "provides an ILLiad URL" do
    illiad = described_class.new(enum: "Volume foo", chron: "Chronicle 1")
    expect(illiad.illiad_request_url(ctx)).to start_with(Requests::Config[:ill_base])
  end

  it "provides illiad query parameters with enumeration" do
    illiad = described_class.new(enum: "Volume foo", chron: "Chronicle 1")
    expect(illiad.illiad_request_url(ctx)).to include(CGI.escape("Volume foo"))
  end
end
