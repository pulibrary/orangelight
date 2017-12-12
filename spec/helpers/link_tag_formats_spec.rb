require 'rails_helper'

RSpec.describe ApplicationHelper do
  context 'A voyager record' do
    describe '#formats_to_exclude' do
      let(:document) do
        {
          id: '1',
          'holdings_1display' => %({"9092827":{"location":"Firestone Library","library":"Firestone Library","location_code":"f","call_number":"PS3566.I428 A6 2015","call_number_browse":"PS3566.I428 A6 2015"}})
        }.with_indifferent_access
      end

      it 'does not exclude marc derived export formats' do
        expect(formats_to_exclude(document).length).to eq(0)
      end
    end
  end

  context 'A non-voyager record' do
    describe '#formats_to_exclude' do
      let(:document) do
        {
          'holdings_1display' => %({"thesis":{"location":"Online","library":"Online","location_code":"elf1","call_number":"AC102","call_number_browse":"AC102","dspace":true}})
        }.with_indifferent_access
      end
      let(:exclude_formats) do
        %i[marc marcxml refworks_marc_txt endnote openurl_ctx_kev]
      end

      it 'excludes marc derived export formats' do
        expect(formats_to_exclude(document).length).to eq(5)
        expect(formats_to_exclude(document)).to eq(exclude_formats)
      end
    end
  end
end
