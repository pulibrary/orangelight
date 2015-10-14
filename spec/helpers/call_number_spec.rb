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
    let(:first_result) { result.first }
    context "when there's more than two call numbers" do
      let(:call_number) { [ "1", "2", "3" ] }
      it "displays Multiple Holdings" do
        expect(result).to include "Multiple Holdings"
      end
      it "has an availability icon" do
        expect(result).to have_selector ".availability-icon[title='Click on the record for full availability info']"
      end
    end
    context "when given a call number, location, and location code" do
      it "returns a good string" do
        expect(first_result).to include call_number.first
        expect(first_result).to include location_code.first
        expect(first_result).to include location.first
      end
      it "tags the location code" do
        expect(first_result).to have_selector "*[data-loc-code='f']"
      end
      it "tags the record id" do
        expect(first_result).to have_selector "*[data-availability-record][data-record-id='1']"
      end
      it "wraps the record" do
        expect(first_result).to have_selector "*[data-availability-record]"
      end
      it "has an availability icon" do
        expect(first_result).to have_selector ".availability-icon"
      end
    end
  end
end
