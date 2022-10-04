# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::JoinProcessor do
  let(:values) { ['Chapter 1', 'Chapter 2'] }
  let(:config) { Blacklight::Configuration::Field.new(key: 'field') }
  let(:document) { SolrDocument.new }
  let(:options) do
    { context: 'show' }
  end
  let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
  let(:processor) { described_class.new(values, config, document, {}, options, stack) }

  it 'concatenates values into an unordered list' do
    expect(processor.render).to eq('<ul><li class="blacklight-field" dir="ltr">Chapter 1</li><li class="blacklight-field" dir="ltr">Chapter 2</li></ul>')
  end

  context 'only one value passed' do
    let(:values) { ['single value'] }
    it 'does not convert it into a list' do
      expect(processor.render).to eq('single value')
    end
  end

  context 'RTL language string' do
    let(:values) { ['دواني، محمد بن اسعد', 'Chapter 2'] }
    it 'marks the direction of the <li> as rtl' do
      expect(processor.render).to eq('<ul><li class="blacklight-field" dir="rtl">دواني، محمد بن اسعد</li><li class="blacklight-field" dir="ltr">Chapter 2</li></ul>')
    end
  end

  context 'HTML that includes RTL content' do
    let(:values) { ['<span dir="rtl">תל אביב</span> <a dir="ltr">[Browse]</a>'.html_safe, '<span dir="ltr">Tel Aviv</span>'.html_safe] }
    it 'marks the direction of the <li> as rtl' do
      expect(processor.render).to eq('<ul><li class="blacklight-field" dir="rtl"><span dir="rtl">תל אביב</span> <a dir="ltr">[Browse]</a></li><li class="blacklight-field" dir="ltr"><span dir="ltr">Tel Aviv</span></li></ul>')
    end
  end

  context 'field is configured to have a maximum initial display' do
    let(:config) { Blacklight::Configuration::Field.new(key: 'field', maxInitialDisplay: 1) }

    it 'hides values after it hits the configured maximum' do
      expect(processor.render).to eq('<ul><li class="blacklight-field" dir="ltr">Chapter 1</li><li class="blacklight-field d-none" dir="ltr">Chapter 2</li></ul>')
    end
  end
end
