# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::HoldingNotesComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(holding, holding_id, adapter))
  end
  let(:holding_id) { "22749747440006421" }
  let(:doc_id) { "9967918863506421" }
  let(:adapter) do
    double(
      shelving_title?: false,
      location_note?: false,
      location_has?: false,
      supplements?: false,
      indexes?: false,
      journal?: false,
      doc_id: "adapter_doc_id"
    )
  end
  let(:holding) { {} }

  context "when shelving_title is present" do
    let(:holding) { { "shelving_title" => ["Title 1", "Title 2"] } }
    before { allow(adapter).to receive(:shelving_title?).with(holding).and_return(true) }

    it "renders shelving title list" do
      expect(rendered.css("ul.shelving-title")).to be_present
      expect(rendered.text).to include("Shelving title")
      expect(rendered.text).to include("Title 1")
      expect(rendered.text).to include("Title 2")
    end
  end

  context "when location_note is present" do
    let(:holding) { { "location_note" => ["Note 1"] } }
    before { allow(adapter).to receive(:location_note?).with(holding).and_return(true) }

    it "renders location note list" do
      expect(rendered.css("ul.location-note")).to be_present
      expect(rendered.text).to include("Location note")
      expect(rendered.text).to include("Note 1")
    end
  end

  context "when location_has is present" do
    let(:holding) { { "location_has" => ["Has 1"] } }
    before { allow(adapter).to receive(:location_has?).with(holding).and_return(true) }

    it "renders location has list" do
      expect(rendered.css("ul.location-has")).to be_present
      expect(rendered.text).to include("Has 1")
    end
  end

  context "when supplements are present" do
    let(:holding) { { "supplements" => ["Supp 1"] } }
    before { allow(adapter).to receive(:supplements?).with(holding).and_return(true) }

    it "renders supplements list" do
      expect(rendered.css("ul.holding-supplements")).to be_present
      expect(rendered.text).to include("Supplements")
      expect(rendered.text).to include("Supp 1")
    end
  end

  context "when indexes are present" do
    let(:holding) { { "indexes" => ["Index 1"] } }
    before { allow(adapter).to receive(:indexes?).with(holding).and_return(true) }

    it "renders indexes list" do
      expect(rendered.css("ul.holding-indexes")).to be_present
      expect(rendered.text).to include("Indexes")
      expect(rendered.text).to include("Index 1")
    end
  end

  context "when journal is true" do
    before { allow(adapter).to receive(:journal?).and_return(true) }

    it "renders journal issues list" do
      expect(rendered.css("ul.journal-current-issues")).to be_present
      expect(rendered.css("ul.journal-current-issues")[0]["data-journal"]).to eq("true")
      expect(rendered.css("ul.journal-current-issues")[0]["data-holding-id"]).to eq(holding_id)
    end
  end

  context "multi_item_availability" do
    let(:holding) { { "mms_id" => doc_id } }

    it "renders item-status ul with correct data attributes" do
      expect(rendered.css("ul.item-status")).to be_present
      expect(rendered.css("ul.item-status")[0]["data-record-id"]).to eq(doc_id)
      expect(rendered.css("ul.item-status")[0]["data-holding-id"]).to eq(holding_id)
    end

    context "when mms_id is missing" do
      let(:holding) { {} }
      it "uses adapter.doc_id" do
        expect(rendered.css("ul.item-status")[0]["data-record-id"]).to eq("adapter_doc_id")
      end
    end
  end

  context "holding_details" do
    let(:holding) { { "shelving_title" => ["Title 1"] } }
    before { allow(adapter).to receive(:shelving_title?).with(holding).and_return(true) }

    it "wraps notes in .holding-details" do
      expect(rendered.css(".holding-details")).to be_present
      expect(rendered.css(".holding-details").text).to include("Shelving title")
    end
  end
end
