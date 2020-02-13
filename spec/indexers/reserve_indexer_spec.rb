# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReserveIndexer do
  describe ".connection_url" do
    context "when an env value is given" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RESERVES_CORE").and_return("reserves")
        allow(ENV).to receive(:[]).with("RESERVES_SOLR_URL").and_return("http://example.com/remote_solr/reserves")
      end
      it "returns the configured value" do
        expect(described_class.connection_url).to eq "http://example.com/remote_solr/reserves"
      end
    end

    context "when no env value is given" do
      it "returns the default catalog index location" do
        expect(described_class.connection_url).to eq "http://127.0.0.1:8888/solr/orangelight-core-test"
      end
    end
  end
end
