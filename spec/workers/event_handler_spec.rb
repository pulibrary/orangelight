# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventHandler do
  let(:handler) { described_class.new }

  describe '#work' do
    let(:processor) { instance_double(EventProcessor, process: process) }
    let(:process) {}
    let(:msg) do
      {
        'event' => 'CREATED'
      }
    end

    before do
      allow(handler).to receive(:ack!)
      allow(handler).to receive(:reject!)
    end

    context 'when processing is successful' do
      let(:process) { true }

      it 'sends the message to the EventProcessor as a hash' do
        allow(EventProcessor).to receive(:new).and_return(processor)
        handler.work(msg.to_json)
        expect(processor).to have_received(:process)
        expect(EventProcessor).to have_received(:new).with(msg)
        expect(handler).to have_received(:ack!)
      end
    end

    context 'when processing is fails' do
      let(:process) { false }

      it 'rejects the message' do
        allow(EventProcessor).to receive(:new).and_return(processor)
        handler.work(msg.to_json)
        expect(processor).to have_received(:process)
        expect(EventProcessor).to have_received(:new).with(msg)
        expect(handler).to have_received(:reject!)
      end
    end
  end
end
