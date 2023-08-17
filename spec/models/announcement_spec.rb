# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Announcement, type: :model do
  it 'can be instantiated' do
    described_class.create(text: "My announcement text")
    expect(described_class.last.text).to eq("My announcement text")
  end
end
