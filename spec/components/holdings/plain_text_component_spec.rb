# frozen_string_literal: true

require "rails_helper"

RSpec.describe Holdings::PlainTextComponent, type: :component do
  it "renders a nice format of the record's holdings_all_display" do
    holdings_all_display = { "9034559" => { "location" => "Remote Storage", "library" => "ReCAP", "call_number" => "DT194 .A439 2016" },
                             "12345" => { "location" => "Remote Storage (ReCAP): Lewis Library Use Only", "library" => "Lewis Library", "call_number" => "8001.846" } }
    document = instance_double(SolrDocument)
    allow(document).to receive(:holdings_all_display).and_return holdings_all_display

    expect(render_inline(described_class.new(document)).text).to include "\n\tLocation: ReCAP - Remote Storage\n\tCall number: DT194 .A439 2016"
    expect(render_inline(described_class.new(document)).text).to include "\n\tLocation: Lewis Library - Remote Storage (ReCAP): Lewis Library Use Only\n\tCall number: 8001.846"
  end
end
