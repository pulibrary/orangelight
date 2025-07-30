# frozen_string_literal: true
require "rails_helper"

RSpec.describe Holdings::PhysicalHoldingComponent, type: :component do
  let(:adapter) { double("Adapter") }
  let(:holding_id) { "holding-123" }
  let(:holding) { { "mms_id" => "doc-456" } }
  let(:location_rules) do
    JSON.parse '{"label":"Reserve 3-Hour","code":"arch$res3hr","aeon_location":false,"recap_electronic_delivery_location":false,"open":false,"requestable":false,"always_requestable":false,"circulates":false,"remote_storage":"","fulfillment_unit":"Reserves","library":{"label":"Architecture Library","code":"arch","order":0},"holding_library":null,"delivery_locations":[{"label":"Architecture Library","address":"School of Architecture Building, Second Floor Princeton, NJ 08544","phone_number":"609-258-3256","contact_email":"ues@princeton.edu","gfa_pickup":"PW","staff_only":false,"pickup_location":true,"digital_location":true,"library":{"label":"Architecture Library","code":"arch","order":0}}]}'
  end
  before do
    stub_holding_locations
    allow(adapter).to receive(:location_has?).and_return(false)
    allow(adapter).to receive(:supplements?).and_return(false)
    allow(adapter).to receive(:location_note?).and_return(false)
    allow(adapter).to receive(:indexes?).and_return(false)
    allow(adapter).to receive(:journal?).and_return(false)
    allow(adapter).to receive(:sc_location_with_suppressed_button?).and_return(false)
    allow(adapter).to receive(:shelving_title?).and_return(false)
    allow(adapter).to receive(:temp_location_code).and_return("arch$res3hr")
    allow(adapter).to receive(:alma_holding?).and_return(true)
    allow(adapter).to receive(:holding_location_rules).and_return(location_rules)
    allow(adapter).to receive(:call_number).and_return("QA123 .B45")
    allow(adapter).to receive(:repository_holding?).and_return(false)
    allow(adapter).to receive(:scsb_holding?).and_return(false)
    allow(adapter).to receive(:empty_holding?).and_return(false)
    allow(adapter).to receive(:unavailable_holding?).and_return(false)
    allow(adapter).to receive(:doc_id).and_return("doc-456")
  end

  it "renders the holding block with call number, availability, services, and notes" do
    render_inline described_class.new(adapter, holding_id, holding)
    expect(rendered_content).to include("QA123 .B45")
    expect(rendered_content).to include("holding-block")
  end

  context "when holding is unavailable" do
    before { allow(adapter).to receive(:unavailable_holding?).and_return(true) }

    it "renders unavailable status" do
      render_inline described_class.new(adapter, holding_id, holding)
      expect(rendered_content).to include("Unavailable")
      expect(rendered_content).to include("bg-danger")
    end
  end

  context "when holding is a repository holding" do
    before { allow(adapter).to receive(:repository_holding?).and_return(true) }

    it "renders on-site access status" do
      render_inline described_class.new(adapter, holding_id, holding)
      expect(rendered_content).to include("On-site access")
      expect(rendered_content).to include("bg-success")
    end
  end
end
