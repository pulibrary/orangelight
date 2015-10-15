require 'rails_helper'

RSpec.describe SolrDocument::Identifier do
  subject { described_class.new(type, value) }
  let(:type) { "isbn_s" }
  let(:value) { "0" }
  describe "#value" do
    it "returns the value given" do
      expect(subject.value).to eq "0"
    end
  end
  describe "#to_html" do
    it "returns a meta tag" do
      expect(subject.to_html).to eq "<meta property=\"isbn\" itemprop=\"isbn\" content=\"0\" />"
    end
  end
  context "for an lccn" do
    let(:type) { "lccn_s" }
    let(:value) { "0" }
    describe "#property" do
      it "returns lccn" do
        expect(subject.property).to eq "lccn"
      end
    end

    describe "#itemprop" do
      it "returns nil" do
        expect(subject.itemprop).to eq nil
      end
    end

  end

  context "for an isbn" do
    let(:type) { "isbn_s" }
    describe "#property" do
      it "returns isbn" do
        expect(subject.property).to eq "isbn"
      end
    end
    
    describe "#itemprop" do
      it "returns isbn" do
        expect(subject.itemprop).to eq "isbn"
      end
    end
  end

  context "for an oclc number" do
    let(:type) { "oclc_s" }
    describe "#property" do
      it "returns an RDF URI" do
        expect(subject.property).to eq "http://purl.org/library/oclcnum"
      end
    end

    describe "#itemprop" do
      it "returns nil" do
        expect(subject.itemprop).to eq nil
      end
    end
  end
end
