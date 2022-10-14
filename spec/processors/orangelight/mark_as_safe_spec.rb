# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::MarkAsSafeProcessor do
  let(:values) { ['<my html>'] }
  let(:config) { Blacklight::Configuration::Field.new(key: 'field', mark_as_safe: true) }
  let(:document) { SolrDocument.new }
  let(:options) do
    { context: 'show' }
  end
  let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
  let(:processor) { described_class.new(values, config, document, {}, options, stack) }
  let(:rendered) { processor.render }

  it 'marks strings as html safe' do
    expect(rendered.first.html_safe?).to eq(true)
  end
  context 'mark_as_safe is not configured to true' do
    let(:config) { Blacklight::Configuration::Field.new(key: 'field', mark_as_safe: false) }
    it 'does not mark strings as html safe' do
      expect(rendered.first.html_safe?).to eq(false)
    end
  end
end
