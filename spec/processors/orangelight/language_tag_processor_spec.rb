# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::LanguageTagProcessor do
  it 'adds a language tag if configured to do so' do
    processor = described_class.new(
      ['ABC'],
      Blacklight::Configuration::Field.new(language_tag: true),
      SolrDocument.new({ language_iana_s: ['ar'] }),
      {},
      { context: 'show' },
      [Blacklight::Rendering::Terminator]
    )
    expect(processor.render).to eq(['<span lang="ar">ABC</span>'])
  end
  it 'does not add a language tag if the document does not have one' do
    processor = described_class.new(
      ['ABC'],
      Blacklight::Configuration::Field.new(language_tag: true),
      SolrDocument.new,
      {},
      { context: 'show' },
      [Blacklight::Rendering::Terminator]
    )
    expect(processor.render).to eq(['ABC'])
  end
  it 'does not add a language tag if the field is not configured to do so' do
    processor = described_class.new(
      ['ABC'],
      Blacklight::Configuration::Field.new,
      SolrDocument.new({ language_iana_s: ['ar'] }),
      {},
      { context: 'show' },
      [Blacklight::Rendering::Terminator]
    )
    expect(processor.render).to eq(['ABC'])
  end
end
