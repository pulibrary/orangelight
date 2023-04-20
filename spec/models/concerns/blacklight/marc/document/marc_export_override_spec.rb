# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Blacklight::Marc::Document::MarcExportOverride do
  describe "#clean_end_punctuation" do
    # See https://mixandgo.com/learn/how-to-test-ruby-modules-with-rspec for information on
    # testing methods defined in modules.
    let(:sample_class) do
      Class.new do
        include Blacklight::Marc::Document::MarcExportOverride
      end
    end

    it 'handles nil values' do
      expect(sample_class.new.clean_end_punctuation(nil)).to eq ""
    end
  end
end
