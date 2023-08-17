# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_announcement' do
  let!(:announcement) { FactoryBot.create(:announcement) }

  it 'renders an announcement' do
    render
    expect(rendered).to match(//)
  end

  context 'in read-only mode' do
    it 'renders a read-only message' do
      allow(Orangelight).to receive(:read_only_mode).and_return(true)
      allow(Orangelight).to receive(:read_only_message).and_return("test message")
      render
      expect(rendered).to match(/test message/)
    end
  end

  context 'with a non-read-only announcement' do
    before do
      allow(Flipflop).to receive(:message_display?).and_return(true)
      allow(Orangelight).to receive(:read_only_mode).and_return(false)
    end

    it 'displays the message' do
      render
      expect(rendered).to match(/#{announcement.text}/)
    end
  end
  context 'without a non-read-only announcement' do
    before do
      allow(Flipflop).to receive(:message_display?).and_return(false)
    end

    it 'renders an empty announcement partial' do
      render
      expect(rendered).to match(//)
    end
  end
end
