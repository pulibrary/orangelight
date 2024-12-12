# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'orangelight/record_mailer/email_record' do
  before do
    assign(:documents, [SolrDocument.new(properties)])
    assign(:url_gen_params, {})
    allow(view).to receive(:blacklight_config).and_return(CatalogController.blacklight_config.dup)
    render
  end
  describe 'record with vernacular script' do
    let(:properties) do
      {
        id: '9991533593506421',
        title_display: 'al-Amāzīgh : mawsūʻat tārīkh duwal al-Maghrib al-ʻArabī',
        title_vern_display: 'الأمازيغ : موسوعة تاريخ دول المغرب العربي.',
        pub_created_display: ['al-Muhandisīn, al-Jīzah : Dār Halā lil-Nashr wa-al-Tawzīʻ, 2016.',
                              'المهندسين، الجيزة : دار هلا للنشر والتوزيع، 2016.'],
        format: ['Book'],
        holdings_1display: '{"9034559":{"location":"Remote Storage","library":"ReCAP","location_code":"recap$pa",' \
                           '"call_number":"DT194 .A439 2016","call_number_browse":"DT194 .A439 2016",' \
                           '"location_has":["Juzʼ 1-juzʼ 2"]}}'
      }
    end

    it 'includes both Romanized and vernacular script' do
      expect(rendered).to have_text('Title: al-Amāzīgh')
      expect(rendered).to have_text('Title: الأمازيغ')
    end

    it 'includes a label for each value in multivalued field' do
      expect(rendered).to have_text('Published/Created: al-Muhandisīn')
      expect(rendered).to have_text('المهندسين،')
    end

    it 'excludes online information if no links present' do
      expect(rendered).not_to have_text('Online access:')
    end

    it 'includes holding information when present' do
      expect(rendered).to have_text('Holdings:')
    end

    it 'individual holding information is included' do
      expect(rendered).to have_text("Location: ReCAP - Remote Storage")
      expect(rendered).to have_text("Call number: DT194")
    end
  end

  describe 'record with no holdings' do
    let(:properties) { { id: '9991533593506421' } }

    it 'excludes author label when not present' do
      expect(rendered).not_to have_text('Author:')
    end
    it 'excludes holdings label when not present' do
      expect(rendered).not_to have_text('Holdings:')
    end
  end

  describe 'thesis online record' do
    let(:properties) do
      {
        id: 'dsp01zk51vk08g',
        title_display: 'The Adenosine Receptor and Olfactory Dysfunction in Parkinson’s',
        electronic_access_1display: '{"http://arks.princeton.edu/ark:/88435/dsp01zk51vk08g":' \
                                    '["DataSpace","Full text"]}',
        author_display: ['Olajide, Aminah'],
        format: ['Senior Thesis']
      }
    end

    it 'includes online access label' do
      expect(rendered).to have_text('Online access:')
    end
    it 'includes link' do
      expect(rendered).to have_text("Full text - DataSpace: http://arks.princeton.edu")
    end
    it 'includes format' do
      expect(rendered).to have_text('Format: Senior Thesis')
    end
  end
  describe 'bound-with record' do
    let(:properties) do
      {
        id: '9947055653506421',
        contained_in_s: ['12345']
      }
    end
    let(:solr_doc) { SolrDocument.new(properties) }
    before do
      allow(solr_doc).to receive(:doc_by_id).and_return({ 'holdings_1display' => '{"1":{"library":"Firestone"}}' })
      assign(:documents, [solr_doc])
      assign(:url_gen_params, {})
      render
    end
    it 'includes holdings info from the host record' do
      expect(rendered).to have_text('Holdings:')
    end
  end
  describe 'with a message' do
    let(:properties) { { id: '9991533593506421' } }

    before do
      assign(:documents, [SolrDocument.new(properties)])
      assign(:message, 'This is my message')
      assign(:url_gen_params, {})
      render
    end
    it 'includes the message and header' do
      expect(rendered).to have_text('Message:')
      expect(rendered).to have_text('This is my message')
    end
  end
  describe 'without a message' do
    let(:properties) { { id: '9991533593506421' } }

    it 'does not include the message header' do
      expect(rendered).not_to have_text('Message:')
    end
  end
  describe 'with electronic portfolio' do
    let(:properties) do
      {
        id: '9945502073506421',
        title_display: 'The sociology of emotions / Jonathan H. Turner, Jan E. Stets.',
        electronic_access_1display: '{"http://www.loc.gov/catdir/description/cam051/2004018645.html":["Publisher description"],"http://www.loc.gov/catdir/toc/ecip0421/2004018645.html":["Table of contents"]}',
        author_display: ['Turner, Jonathan H.'],
        format: ['Book'],
        electronic_portfolio_s: [
          '{"desc":null,"title":"Full Text","url":"https://na05.alma.exlibrisgroup.com/view/uresolver/01PRI_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53827030770006421&Force_direct=true","start":null,"end":"latest"}',
          '{"desc":null,"title":"Second Title","url":"https://example.com","start":null,"end":"latest"}'
        ]
      }
    end

    it 'includes the electronic portfolio link' do
      expect(rendered).to have_text('Full Text')
      expect(rendered).to have_text('Second Title')
    end
  end
end
