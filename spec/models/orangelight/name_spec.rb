# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::Name do
  describe "alma behavior" do
    after do
      allow(Rails.configuration).to receive(:use_alma).and_call_original
      described_class.reset_table_name
    end
    context "when use_alma is true" do
      it "initializes to the alma tables" do
        allow(Rails.configuration).to receive(:use_alma).and_return(true)
        described_class.reset_table_name

        expect { described_class.new }.not_to raise_error
        expect(described_class.table_name).to eq "alma_orangelight_names"
      end
    end
    context "when use_alma is false" do
      it "initializes to the non-alma tables" do
        allow(Rails.configuration).to receive(:use_alma).and_return(false)
        described_class.reset_table_name

        expect { described_class.new }.not_to raise_error
        expect(described_class.table_name).to eq "orangelight_names"
      end
    end
  end
end
