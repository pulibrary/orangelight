# frozen_string_literal: true
require 'rails_helper'

describe StdoutLogger do
  it 'names the logger so events can be told apart once they are shipped' do
    expect(described_class.build('Sneakers').name).to eq 'Sneakers'
  end

  # Sneakers only keeps the logger we hand it if it responds to these, otherwise
  # it replaces it with one of its own. See Sneakers.setup_general_logger!
  it 'responds to the level methods Sneakers checks for' do
    logger = described_class.build('Sneakers')

    expect(logger).to respond_to(:info, :debug, :error, :warn)
  end

  it 'logs JSON in environments whose logs are shipped' do
    allow(Rails.env).to receive(:local?).and_return false

    expect(described_class.build('Sneakers').formatter).to be_a SemanticLogger::Formatters::Json
  end

  it 'stays human readable when tailing a worker locally' do
    allow(Rails.env).to receive(:local?).and_return true

    expect(described_class.build('Sneakers').formatter).to be_a SemanticLogger::Formatters::Color
  end

  it 'writes one JSON object per event to stdout' do
    allow(Rails.env).to receive(:local?).and_return false

    # Built inside the block on purpose. The appender keeps a reference to
    # whichever $stdout it was handed, and this matcher only swaps $stdout for
    # the duration of the block, so a logger built beforehand would write past
    # it to the real stdout and capture nothing.
    expect do
      described_class.build('Sneakers').info 'Working off', queue: 'figgy_events'
    end.to output(
      a_string_matching(/\A\{.*"name":"Sneakers".*"message":"Working off".*\}\n\z/m)
    ).to_stdout
  end
end
