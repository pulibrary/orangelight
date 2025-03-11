# frozen_string_literal: true

require "rails_helper"

RSpec.describe IndexDocumentComponent, type: :component do
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.track_search_session.storage = false
    end
  end
  before do
    allow_any_instance_of(Blacklight::Document::BookmarkComponent).to receive(:bookmarked?).and_return(false)
    allow_any_instance_of(ActionView::Base).to receive(:search_session).and_return({})
    allow_any_instance_of(ActionView::Base).to receive(:current_search_session)
    allow(vc_test_controller).to receive(:blacklight_config).and_return(blacklight_config)
  end
  subject do
    document = SolrDocument.new(id: 'SCSB-1234')
    presenter = Blacklight::DocumentPresenter.new(document, instance_double(ActionView::Base, action_name: 'show'), blacklight_config)
    allow(presenter).to receive(:fields).and_return([])
    allow(document).to receive(:export_as_openurl_ctx_kev).and_return 'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft.issn=1045-4438'
    render_inline(described_class.new(document:, presenter:))
  end
  it 'puts everything into an article tag' do
    expect(subject.elements.first.name).to eq('article')
  end

  it 'embeds identifiers in a span' do
    expect(subject.css('span[vocab="http://id.loc.gov/vocabulary/identifiers/"]').length).to eq 1
  end

  it 'includes metadata in the COinS format, which Zotero can read', zotero: true do
    expect(subject.css('span.Z3988').first[:title]).to eq 'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rft.issn=1045-4438'
  end
end
