# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings::SearchLocationComponent, type: :component do
  let(:holding_hash) do
    {
      "call_number" => "QA76.73.R83",
      "library" => "firestone"
    }
  end

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationHelper).to receive(:holding_library_label)
      .and_return("Firestone Library")
    # rubocop:enable RSpec/AnyInstance
  end

  it "renders the location label" do
    rendered = render_inline(described_class.new(holding_hash))
    expect(rendered.css('.results_location').text).to include("Firestone Library")
  end

  it "renders the location icon" do
    rendered = render_inline(described_class.new(holding_hash))
    expect(rendered.css('svg').length).to eq 1
  end

  it "renders the call number" do
    rendered = render_inline(described_class.new(holding_hash))
    expect(rendered.css('.call-number').text).to include("QA76.73.R83")
  end

  it "renders both location and call number divs" do
    rendered = render_inline(described_class.new(holding_hash))
    expect(rendered.css('.results_location').length).to eq 1
    expect(rendered.css('.call-number').length).to eq 1
  end
end
