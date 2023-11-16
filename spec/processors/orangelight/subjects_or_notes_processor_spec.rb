# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Orangelight::SubjectsOrNotesProcessor do
  before do
    allow(Flipflop).to receive(:highlighting?).and_return(true)
  end
  let(:document) { SolrDocument.new }
  let(:options) do
    { context: 'show' }
  end
  let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
  let(:processor) { described_class.new(values, config, document, request_context, options, stack) }
  let(:rendered) { processor.render }
  let(:request_context) { double('View context') }

  context "when notes_display and subject_display are present" do
    before do
      allow(document).to receive(:highlight_field).with('lc_subject_display').and_return(values)
      allow(request_context).to receive(:action_name).and_return('index')
    end
    let(:values) { ['The lives of <em>Black</em> and Latino <em>teenagers</em> in a low-income :'] }
    context "notes_display field" do
      let(:config) { Blacklight::Configuration::Field.new(field: 'notes_display') }
      it "will not render" do
        expect(rendered).to be_empty
      end
    end
    context "lc_subject_display field" do
      let(:config) { Blacklight::Configuration::Field.new(field: 'lc_subject_display') }
      it "will render" do
        expect(rendered).not_to be_empty
      end
    end
  end
end
