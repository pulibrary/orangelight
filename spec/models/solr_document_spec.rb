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
          "oclc_s" => ["19590730", "301985443"]
        }
      end
      it "has an identifier object each" do
        expect(subject.identifiers.length).to eq 4
      end
    end
  end
end
