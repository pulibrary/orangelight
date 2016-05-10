require 'rails_helper'

RSpec.describe SolrDocument do
  subject { described_class.new(properties) }
  let(:properties) { {} }

  describe "#identifiers" do
    context "with no identifiers" do
      it "is a blank array" do
        expect(subject.identifiers).to eq []
      end
    end
    context "with identifiers" do
      let(:properties) do
        {
          "lccn_s" => ["2001522653"],
          "isbn_s" => ["9781400827824"],
          "oclc_s" => %w(19590730 301985443)
        }
      end
      it "has an identifier object each" do
        expect(subject.identifiers.length).to eq 4
      end
    end
  end

  describe "#identifier_data" do
    context "with identifiers" do
      let(:properties) do
        {
          "lccn_s" => ["2001522653"],
          "isbn_s" => ["9781400827824"],
          "oclc_s" => %w(19590730 301985443)
        }
      end
      it "returns a hash of identifiers for data embeds" do
        expect(subject.identifier_data).to eq(
          lccn: [
            "2001522653"
          ],
          isbn: [
            "9781400827824"
          ],
          oclc: %w(
            19590730
            301985443)
        )
      end
    end
  end

  describe "Blacklight::Document::Sms" do
    it "does not include any text if call number not present" do
      doc = described_class.new
      sms_text = doc.to_sms_text
      expect(sms_text).to eq ''
    end
    it "includes call number in text" do
      doc = described_class.new(call_number_display: ['AB 4209.3'])
      sms_text = doc.to_sms_text
      expect(sms_text).to match(/AB 4209.3/)
    end
    it "includes all call numbers if there are multiple holdings" do
      doc = described_class.new(call_number_display: ['AB 4209.3', 'Electronic Resource'])
      sms_text = doc.to_sms_text
      expect(sms_text).to match(/AB 4209.3/)
      expect(sms_text).to match(/Electronic Resource/)
    end
    it "includes all call numbers if there are multiple holdings" do
      doc = described_class.new(call_number_display: ['Electronic Resource', 'Electronic Resource', 'Electronic Resource'])
      sms_text = doc.to_sms_text
      expect(sms_text.scan(/Electronic Resource/).length).to eq 1
    end
  end
end
