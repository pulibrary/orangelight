# frozen_string_literal: true

require "rails_helper"

RSpec.describe IndexTitleComponent, type: :component do
  subject do
    render_inline described_class.new(presenter: Blacklight::DocumentPresenter.new(document, instance_double(ActionView::Base, action_name: 'show'), blacklight_config))
  end
  before do
    allow_any_instance_of(Blacklight::Document::BookmarkComponent).to receive(:bookmarked?).and_return(false)
    allow(vc_test_controller).to receive(:current_or_guest_user).and_return(User.new)
    allow_any_instance_of(ActionView::Base).to receive(:search_session).and_return({})
    allow_any_instance_of(ActionView::Base).to receive(:current_search_session)
    allow(vc_test_controller).to receive(:blacklight_config).and_return(blacklight_config)
  end
  let(:blacklight_config) do
    Blacklight::Configuration.new do |config|
      config.track_search_session.storage = false
      config.index.document_actions[:bookmark].partial = '/catalog/bookmark_control'
    end
  end
  context 'when title_display is the only field that has a title' do
    let(:document) do
      SolrDocument.new(title_display: 'Aldeas globales.', id: 'SCSB-1234')
    end
    it 'renders the title from title_display' do
      expect(subject.text).to include('Aldeas globales.')
    end
    it 'renders only one h3' do
      expect(subject.css('h3').length).to eq 1
    end
  end

  context 'when title_vern_display and title_display both have titles and title_vern_display is in a RTL language' do
    let(:document) do
      SolrDocument.new(
        title_display: 'Safīr al-kawārith : riwāyah / Yāsir ʻAbd al-ʻAzīz al-ʻUraynān.',
        title_vern_display: "‏سفير الكوارث :‏ ‏رواية /‏ ‏ياسر عبد العزيز العرينان.",
        id: 'SCSB-1234'
      )
    end
    it 'renders the title from title_vern_display' do
      expect(subject.text).to include("‏سفير الكوارث :‏ ‏رواية /‏ ‏ياسر عبد العزيز العرينان.")
    end
    it 'renders the title from title_display' do
      expect(subject.text).to include('Safīr al-kawārith : riwāyah / Yāsir ʻAbd al-ʻAzīz al-ʻUraynān.')
    end
    it 'renders both titles as h3' do
      expect(subject.css('h3').length).to eq 2
    end
    it 'includes the correct values for the dir attribute' do
      expect(subject.css('h3 a')[0][:dir]).to eq 'rtl' # the Arabic text is right-to-left
      expect(subject.css('h3 a')[1][:dir]).to eq 'ltr' # the Latin transliteration is left-to-right
    end
    it 'adds float right style to the link' do
      expect(subject.css('a').first[:style]).to eq('float: right;')
    end
  end
end
