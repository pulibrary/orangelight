# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_announcement' do
  it 'renders an announcement' do
    render
    expect(rendered).to match(/System upgrade/)
  end

  context 'in read-only mode' do
    it 'renders a read-only message' do
      allow(Orangelight).to receive(:read_only_mode).and_return(true)
      allow(Orangelight).to receive(:read_only_message).and_return("test message")
      render
      expect(rendered).to match(/System upgrade.* test message/)
    end
  end
end
