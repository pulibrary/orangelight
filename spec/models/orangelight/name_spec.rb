# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::Name do
  it "initializes to the alma tables" do
    described_class.reset_table_name

    expect { described_class.new }.not_to raise_error
    expect(described_class.table_name).to eq "alma_orangelight_names"
  end
end
