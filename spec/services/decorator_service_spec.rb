# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DecoratorService::SolrDocumentDecorator do
  it "handles records without a title" do
    solr_doc = SolrDocument.new(id: "99123923123506421", author_display: "Wosk, Yosef")
    service = described_class.new(document: solr_doc)
    expect(service.title).to be nil
  end
end
