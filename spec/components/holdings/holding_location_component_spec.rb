# frozen_string_literal: true
require "rails_helper"

RSpec.describe Holdings::HoldingLocationComponent, type: :component do
  let(:holding) do
    {
      "location" => "Firestone Library",
      "location_code" => "firestone$stacks",
      "library" => "firestone"
    }
  end
  let(:location) { "Firestone Library" }
  let(:holding_id) { "12345" }
  let(:call_number) { "QA76.73.R83" }

  let(:stackmap_factory) { instance_double(StackmapLocationFactory) }

  before do
    stub_holding_locations
    allow(StackmapLocationFactory).to receive(:new).and_return(stackmap_factory)
    allow(stackmap_factory).to receive(:exclude?).and_return(false)
  end

  it "renders a td with the correct class and data attribute" do
    rendered = render_inline(described_class.new(holding, location, holding_id, call_number))
    expect(rendered.css("td.library-location[data-holding-id='#{holding_id}']").length).to eq 1
  end

  it "renders the location text in a span with correct class and data" do
    rendered = render_inline(described_class.new(holding, location, holding_id, call_number))
    expect(rendered.css("span.location-text[data-location='true'][data-holding-id='#{holding_id}']").text).to eq location
  end

  it "renders the stackmap span when not excluded and find_it_location? is true" do
    rendered = render_inline(described_class.new(holding, location, holding_id, call_number))
    expect(rendered.css("span[data-map-location='firestone$stacks'][data-location-library='firestone'][data-location-name='Firestone Library']").length).to eq 1
  end

  it "does not render stackmap span when excluded" do
    allow(stackmap_factory).to receive(:exclude?).and_return(true)
    rendered = render_inline(described_class.new(holding, location, holding_id, call_number))
    expect(rendered.css("span[data-map-location]").length).to eq 0
  end

  it "renders correctly with empty location string" do
    rendered = render_inline(described_class.new(holding, "", holding_id, call_number))
    expect(rendered.css("span.location-text").text).to eq ""
  end

  context 'for a Music library holding' do
    let(:holding) do
      {
        location:,
        library: 'Mendel Music Library',
        location_code: 'mendel$res',
        call_number:
      }.with_indifferent_access
    end
    let(:call_number) { 'CD- 2018-11-11' }
    let(:holding_id) { '22270490550006421' }
    let(:location) { 'Mendel Music Library: Reserve' }

    it 'has the correct markup' do
      holding_location_markup = render_inline(described_class.new(holding, location, holding_id, call_number)).to_s
      expect(holding_location_markup).to include '<td class="library-location"'
      expect(holding_location_markup).to include '<span class="location-text"'
      expect(holding_location_markup).to include 'Mendel Music Library: Reserve'
      expect(holding_location_markup).to include 'data-holding-id="22270490550006421"'
      expect(holding_location_markup).to include "data-map-location=\"#{holding.first[1]['location_code']}"
    end
  end

  context 'Special collections location with suppressed button' do
    let(:holding_id) { '22939015790006421' }
    let(:location) { 'Remote Storage (ReCAP): Manuscripts. Special Collections Use Only' }
    let(:call_number) { '' }
    let(:holding) do
      {

        location:,
        library: 'Special Collections',
        location_code: 'rare$xmr',
        call_number:
      }.with_indifferent_access
    end

    it 'generates the markup for the holding locations' do
      holding_location_markup = render_inline(described_class.new(holding, location, holding_id, call_number)).to_s

      expect(holding_location_markup).to include '<td class="library-location"'
      expect(holding_location_markup).to include '<span class="location-text"'
      expect(holding_location_markup).to include 'Remote Storage (ReCAP): Manuscripts. Special Collections Use Only'
      expect(holding_location_markup).to include 'data-holding-id="22939015790006421"'
    end

    context 'Is a remote storage location rare$xmr' do
      it 'does not have a -where to find- it element' do
        holding_location_markup = render_inline(described_class.new(holding, location, holding_id, call_number)).to_s

        expect(holding_location_markup).not_to include "title"
        expect(holding_location_markup).not_to include "data-map-location"
        expect(holding_location_markup).not_to include "data-location-library"
        expect(holding_location_markup).not_to include "data-location-name"
      end
    end
  end
end
