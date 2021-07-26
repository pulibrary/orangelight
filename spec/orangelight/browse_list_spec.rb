# frozen_string_literal: true
require 'rails_helper'

RSpec.describe BrowseLists do
  describe ".table_prefix" do
    it "is alma_orangelight" do
      expect(described_class.table_prefix).to eq "alma_orangelight"
    end
  end
end
