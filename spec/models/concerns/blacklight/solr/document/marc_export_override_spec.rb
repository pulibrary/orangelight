# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Blacklight::Solr::Document::MarcExportOverride do
  # See https://mixandgo.com/learn/how-to-test-ruby-modules-with-rspec for information on
  # testing methods defined in modules.
  let(:dummy_class) do
    Class.new do
      extend Blacklight::Solr::Document::MarcExportOverride
    end
  end

  it 'handles nil values' do
    expect(dummy_class.clean_end_punctuation(nil)).to eq ""
  end
end
