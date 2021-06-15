# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrowseLists do
  describe ".table_prefix" do
    context "when use_alma is true" do
      it "is alma_orangelight" do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)

        expect(described_class.table_prefix).to eq "alma_orangelight"
      end
    end
    context "when use_alma is false" do
      it "is orangelight" do
        allow(Rails.configuration).to receive(:use_alma).and_return(false)

        expect(described_class.table_prefix).to eq "orangelight"
      end
    end
  end
end
