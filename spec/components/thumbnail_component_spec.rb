# frozen_string_literal: true

require "rails_helper"

RSpec.describe ThumbnailComponent, type: :component, thumbnails: true do
  it "includes identifiers for google books retrieval if the document is not in special collections" do
    document = instance_double(SolrDocument)
    allow(document).to receive_messages(
      in_a_special_collection?: false,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )

    rendered = render_inline(described_class.new(document:))

    expect(rendered.css('.document-thumbnail').attribute('data-oclc').to_s).to eq('["40810988"]')
    expect(rendered.css('.document-thumbnail').attribute('data-bib-id').to_s).to eq('9969113523506421')
  end

  it "includes only the bib-id identifier for figgy retrieval if the document is in special collections" do
    document = instance_double(SolrDocument)
    allow(document).to receive_messages(
      in_a_special_collection?: true,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )

    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('.document-thumbnail').attribute('data-oclc')).to be_nil
    expect(rendered.css('.document-thumbnail').attribute('data-bib-id').to_s).to eq('9969113523506421')
  end

  it 'includes a div.default within a div.document-thumbnail' do
    document = instance_double(SolrDocument)
    allow(document).to receive_messages(
      in_a_special_collection?: true,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )

    rendered = render_inline(described_class.new(document:))

    expect(rendered.css('div.document-thumbnail > div.default')).not_to be_empty
  end
end
