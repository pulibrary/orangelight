require 'rails_helper'

RSpec.describe Blacklight::Document::Email do
  subject { SolrDocument.new(properties).to_email_text }

  describe '#to_email_text' do
    describe 'record with vernacular script' do
      let(:properties) do
        {
          id: '9153359',
          title_display: 'al-Amāzīgh : mawsūʻat tārīkh duwal al-Maghrib al-ʻArabī',
          title_vern_display: 'الأمازيغ : موسوعة تاريخ دول المغرب العربي.',
          pub_created_display: ['al-Muhandisīn, al-Jīzah : Dār Halā lil-Nashr wa-al-Tawzīʻ, 2016.',
                                'المهندسين، الجيزة : دار هلا للنشر والتوزيع، 2016.'],
          format: ['Book'],
          holdings_1display: '{"9034559":{"location":"ReCAP","library":"ReCAP","location_code":"rcppa",'\
                             '"call_number":"DT194 .A439 2016","call_number_browse":"DT194 .A439 2016",'\
                             '"location_has":["Juzʼ 1-juzʼ 2"]}}'
        }
      end
      it 'includes both Romanized and vernacular script' do
        expect(subject).to match('Title: al-Amāzīgh')
        expect(subject).to match('Title: الأمازيغ')
      end
      it 'includes a label for each value in multivalued field' do
        expect(subject).to match('Published\/Created: al-Muhandisīn')
        expect(subject).to match('Published\/Created: المهندسين،')
      end
      it 'excludes online information if no links present' do
        expect(subject).not_to match('Online access:')
      end
      it 'includes holding information when present' do
        expect(subject).to match('Holdings:')
      end
      it 'individual holding information is tabbed' do
        expect(subject).to match("\tLocation: ReCAP")
        expect(subject).to match("\tCall number: DT194")
      end
    end
    describe 'record with no holdings' do
      let(:properties) { {} }
      it 'excludes author label when not present' do
        expect(subject).not_to match('Author:')
      end
      it 'excludes holdings label when not present' do
        expect(subject).not_to match('Holdings:')
      end
    end
    describe 'thesis online record' do
      let(:properties) do
        {
          id: 'dsp01zk51vk08g',
          title_display: 'The Adenosine Receptor and Olfactory Dysfunction in Parkinson’s',
          electronic_access_1display: '{"http://arks.princeton.edu/ark:/88435/dsp01zk51vk08g":'\
                                      '["DataSpace","Full text"]}',
          author_display: ['Olajide, Aminah'],
          holdings_1display: '{"Thesis":{"library":"Online", "location_code":"elfthesis"}}',
          format: ['Senior Thesis']
        }
      end
      it 'includes online access label' do
        expect(subject).to match('Online access:')
      end
      it 'includes link with link text tabbed over' do
        expect(subject).to match("\tFull text - DataSpace: http://arks.princeton.edu")
      end
      it 'includes format' do
        expect(subject).to match('Format: Senior Thesis')
      end
      it 'includes library name when location field is not present in holdings' do
        expect(subject).to match('Location: Online')
      end
    end
  end
end
