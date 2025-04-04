# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GuidedFormSearchBuilder, guided_search: true do
  subject(:builder) { described_class.new([], scope) }

  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { Blacklight::SearchService.new config: blacklight_config, search_state: state }
  let(:state) { Blacklight::SearchState.new({}, blacklight_config) }

  it "puts everything in an edismax query" do
    
  end
end
