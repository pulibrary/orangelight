require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe "#holding_block_search" do
    let(:call_number) { [ "Firestone Library iPads" ]}
    let(:location) { [ "Firestone Library" ] }
    let(:location_code) { [ "f" ] }
    let(:result) { helper.holding_block_search(field_config) }
    let(:field_config) do
      {
        field: :call_number_display,
        document: {
          id: '1',
          location: location,
          location_code_s: location_code,
          call_number_display: call_number
        }
      }.with_indifferent_access
    end
    context "when given a call number, location, and location code" do
      it "returns a good string" do
        first_result = result.first
        expect(first_result).to include call_number.first
        expect(first_result).to include location_code.first
        expect(first_result).to include location.first
      end
      it "tags the location code" do
        first_result = result.first
        expect(first_result).to include "<span data-availability-identifier=\"loc-code\">f</span>"
      end
      it "tags the location" do
        first_result = result.first
        expect(first_result).to include "<span data-availability-identifier=\"location\">Firestone Library</span>"
      end
      it "tags the record id" do
        first_result = result.first
        expect(first_result).to include "<span data-availability-identifier=\"record-id\">1</span>"
      end
      it "wraps the record" do
        first_result = result.first
        expect(first_result).to have_selector "*[data-availability-record]"
      end
    end
  end
end
