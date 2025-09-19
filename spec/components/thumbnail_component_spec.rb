# frozen_string_literal: true
require "rails_helper"

RSpec.shared_examples "thumbnail identifier checks" do |action|
  it "includes identifiers for google books retrieval if the document is not in special collections" do
    allow(document).to receive_messages(
      uuid?: false,
      in_a_special_collection?: false,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )
    allow(document).to receive(:[]).with("electronic_access_1display").and_return(nil)
    allow(component).to receive(:action_name).and_return(action)
    rendered = render_inline(component)
    expect(rendered.css('.document-thumbnail').attribute('data-oclc').to_s).to eq('["40810988"]')
    expect(rendered.css('.document-thumbnail').attribute('data-bib-id').to_s).to eq('9969113523506421')
  end

  it "includes only the bib-id identifier for figgy retrieval if the document is in special collections" do
    allow(document).to receive_messages(
      uuid?: false,
      in_a_special_collection?: true,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )
    allow(document).to receive(:[]).with("electronic_access_1display").and_return(nil)
    allow(component).to receive(:action_name).and_return(action)
    rendered = render_inline(component)
    expect(rendered.css('.document-thumbnail').attribute('data-oclc')).to be_nil
    expect(rendered.css('.document-thumbnail').attribute('data-bib-id').to_s).to eq('9969113523506421')
  end

  it 'includes a div.default within a div.document-thumbnail' do
    allow(document).to receive_messages(
      uuid?: false,
      in_a_special_collection?: true,
      identifier_data: { oclc: ["40810988"], 'bib-id': "9969113523506421" }
    )
    allow(document).to receive(:[]).with("electronic_access_1display").and_return(nil)
    allow(component).to receive(:action_name).and_return(action)
    rendered = render_inline(component)
    expect(rendered.css('div.document-thumbnail > div.default')).not_to be_empty
  end
end

RSpec.describe ThumbnailComponent, type: :component, thumbnails: true do
  let(:document) { instance_double(SolrDocument) }
  let(:component) { described_class.new(document:) }

  context "when rendering a thumbnail in the search results page" do
    before do
      allow(component).to receive(:action_name).and_return('index')
    end

    it "an ephemera document thumbnail does not have a viewer link or a tag viewer-container" do
      allow(document).to receive(:uuid?).and_return(true)
      allow(document).to receive(:[]).with("thumbnail_display").and_return("/thumb.jpg")
      allow(document).to receive(:[]).with("id").and_return("123")
      allow(document).to receive(:in_a_special_collection?).and_return(false)
      allow(document).to receive(:identifier_data).and_return({ oclc: ["40810988"], 'bib-id': "123" })

      rendered = render_inline(component)
      expect(rendered.css('img').attribute('src').to_s).to eq('/thumb.jpg')
      expect(rendered.css('a').length).to eq 0
      expect(rendered.css('span.visually-hidden').length).to eq 0
      expect(rendered.css('.has-viewer-link').length).to eq 0
    end
  end
  context "when rendering a thumbnail in the record page" do
    before do
      allow(component).to receive(:action_name).and_return('show')
    end
    it "an ephemera document thumbnail has a viewer link and a tag viewer-container" do
      allow(document).to receive(:uuid?).and_return(true)
      allow(document).to receive(:[]).with("thumbnail_display").and_return("/thumb.jpg")
      allow(document).to receive(:[]).with("id").and_return("123")
      allow(document).to receive(:in_a_special_collection?).and_return(false)
      allow(document).to receive(:identifier_data).and_return({ oclc: ["40810988"], 'bib-id': "123" })

      rendered = render_inline(component)
      expect(rendered.css('.document-thumbnail.has-viewer-link').attribute('data-bib-id').to_s).to eq('123')
      expect(rendered.css('img').attribute('src').to_s).to eq('/thumb.jpg')
      expect(rendered.css('span.visually-hidden').text).to eq('Go to viewer')
      expect(rendered.css('a').attribute('href').to_s).to eq('#viewer-container')
    end
  end

  context "other cases when rendering a thumbnail in the search results page" do
    it_behaves_like "thumbnail identifier checks", 'index'
  end
  context "other cases when rendering a thumbnail in the record page" do
    it_behaves_like "thumbnail identifier checks", 'show'
  end
end
