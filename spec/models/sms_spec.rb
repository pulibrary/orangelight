require 'rails_helper'

RSpec.describe Blacklight::Document::Sms do
  describe '#to_sms_text' do
    it 'does not include any text if call number not present' do
      doc = SolrDocument.new
      sms_text = doc.to_sms_text
      expect(sms_text).to eq ''
    end
    it 'includes call number in text' do
      doc = SolrDocument.new(call_number_display: ['AB 4209.3'])
      sms_text = doc.to_sms_text
      expect(sms_text).to match(/AB 4209.3/)
    end
    it 'includes all call numbers if there are multiple holdings' do
      doc = SolrDocument.new(call_number_display: ['AB 4209.3', 'Electronic Resource'])
      sms_text = doc.to_sms_text
      expect(sms_text).to match(/AB 4209.3/)
      expect(sms_text).to match(/Electronic Resource/)
    end
    it 'Removes duplicate call numbers' do
      cn = 'Electronic Resource'
      doc = SolrDocument.new(call_number_display: [cn, cn, cn])
      sms_text = doc.to_sms_text
      expect(sms_text.scan(/Electronic Resource/).length).to eq 1
    end
  end
end
