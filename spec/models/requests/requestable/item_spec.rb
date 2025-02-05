# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::Item, requests: true do
  describe '#location' do
    it 'returns the item location as a string' do
      item = described_class.new(
        { "barcode": "32101093374757", "id": "23579848210006421", "holding_id": "22579848330006421", "copy_number": "1", "status": "Available",
          "status_label": "Item in place", "status_source": "base_status", "process_type": nil, "on_reserve": "N", "item_type": "Gen",
          "pickup_location_id": "firestone", "pickup_location_code": "firestone", "location": "firestone$pf", "label": "Firestone Library",
          "description": "Jul 1904 - Dec 1905 Incl: Index NS Vol 20 - 22 Iss 496 - 574", "enum_display": "Jul 1904 - Dec 1905 Incl: Index",
          "chron_display": "NS Vol 20 - 22 Iss 496 - 574", "in_temp_library": false }.with_indifferent_access
      )
      expect(item.location).to eq 'firestone$pf'
    end
    it 'returns nil if no location code is available' do
      item = described_class.new({ "barcode": "32101093374757" }.with_indifferent_access)
      expect(item.location).to be_nil
    end
  end
  describe '#description' do
    it 'can take description from the description field' do
      item = described_class.new({
        "description": "Jul 1904 - Dec 1905 Incl: Index NS Vol 20 - 22 Iss 496 - 574"
      }.with_indifferent_access)
      expect(item.description).to eq 'Jul 1904 - Dec 1905 Incl: Index NS Vol 20 - 22 Iss 496 - 574'
    end
    it 'ignores the legacy enumeration field' do
      item = described_class.new({
        "enumeration": "Jul 1904 - Dec 1905 Incl: Index NS Vol 20 - 22 Iss 496 - 574"
      }.with_indifferent_access)
      expect(item.description).to eq ''
    end
  end
end
