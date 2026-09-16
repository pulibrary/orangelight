# frozen_string_literal: true
require 'rails_helper'

MyTestingStruct = Struct.new(:field) do
  def to_json(*_args) = to_h.to_json
end

describe LogFilter do
  it 'does not mutate typical log messages' do
    event = new_log_event
    expect { described_class.call(event) }.not_to(change { event })
  end

  it 'returns true for typical log messages, indicating that we should log the message' do
    event = new_log_event
    expect(described_class.call(event)).to be true
  end

  it 'keeps deeply nested Hashes and Arrays in a payload' do
    event = new_log_event payload: { data: [
      1,
      20.5,
      { call_me_ishmael: [
        'some years ago',
        ['never', 'mind', 'how', 'long', 'precisely']
      ] }
    ] }

    expect { described_class.call(event) }.not_to(change { event })
  end

  it 'removes complex objects from the payload' do
    event = new_log_event payload: { data: MyTestingStruct.new('hello!') }

    result = described_class.call(event)

    expect(event.payload).to be_empty
    expect(result).to be true
  end

  it 'removes deeply complex objects from arrays within the payload' do
    event = new_log_event payload: { data: { observations: [1, 2, 3, MyTestingStruct.new('hello!')] } }

    result = described_class.call(event)

    expect(event.payload).to eq({ data: { observations: [1, 2, 3] } })
    expect(result).to be true
  end

  it 'removes infinite self-recursion from a payload' do
    a = MyTestingStruct.new
    b = MyTestingStruct.new(a)
    a.field = b

    # Confirm that our payload is infinitely recursive
    expect { a.to_json }.to raise_error(SystemStackError)

    event = new_log_event payload: { my_recursive_data: a, my_good_data: { observations: [1, 2, 3] } }
    result = described_class.call(event)
    expect(event.payload).to eq({ my_good_data: { observations: [1, 2, 3] } })
    expect(result).to be true
  end

  def new_log_event(level: :warn, message: 'relevant info', payload: { relevant: ['data'] })
    event = SemanticLogger::Log.new 'my log', level
    event.assign(message:, payload:)
    event
  end
end
