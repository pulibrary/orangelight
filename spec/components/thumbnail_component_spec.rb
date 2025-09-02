# frozen_string_literal: true

require "rails_helper"

RSpec.describe ThumbnailComponent, type: :component, thumbnails: true do
  it "includes identifiers for google books retrieval if the document is not in special collections" do
    document = instance_double(SolrDocument)
    allow(document).to receive_messages(
      uuid?: false,
      in_a_special_collection?: false,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )

    rendered = render_inline(described_class.new(document:))

    expect(rendered.css('.document-thumbnail').attribute('data-oclc').to_s).to eq('["40810988"]')
    expect(rendered.css('.document-thumbnail').attribute('data-bib-id').to_s).to eq('9969113523506421')
  end

  it "renders a viewer link and thumbnail image when document has uuid and thumbnail_display" do
    document = instance_double(SolrDocument)
    allow(document).to receive(:uuid?).and_return(true)
    allow(document).to receive(:[]).with("thumbnail_display").and_return("/thumb.jpg")
    allow(document).to receive(:[]).with("id").and_return("123")
    allow(document).to receive(:in_a_special_collection?).and_return(false)
    allow(document).to receive(:identifier_data).and_return({ oclc: ["40810988"], 'bib-id': "123" })

    rendered = render_inline(described_class.new(document:))
    expect(rendered.css('a[href="#viewer-container"]')).not_to be_empty
    expect(rendered.css('.document-thumbnail.has-viewer-link').attribute('data-bib-id').to_s).to eq('123')
    expect(rendered.css('img').attribute('src').to_s).to eq('/thumb.jpg')
    expect(rendered.css('span.visually-hidden').text).to eq('Go to viewer')
  end

  it "includes only the bib-id identifier for figgy retrieval if the document is in special collections" do
    document = instance_double(SolrDocument)
    allow(document).to receive_messages(
      uuid?: false,
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
      uuid?: false,
      in_a_special_collection?: true,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )

    rendered = render_inline(described_class.new(document:))

    expect(rendered.css('div.document-thumbnail > div.default')).not_to be_empty
  end
end
