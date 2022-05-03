# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/_search_form' do
  let(:blacklight_controller) { CatalogController.new }
  let(:blacklight_config) { blacklight_controller.blacklight_config }
  let(:presenter) { instance_double(Blacklight::SearchBarPresenter, autofocus?: true, autocomplete_enabled?: false) }
  let(:search_fields) { [["Keyword", "all_fields"], ["Title", "title"], ["Author/Creator", "author"], ["Subject", "subject"], ["Title starts with", "left_anchor"], ["Subject (browse)", "browse_subject"], ["Author (browse)", "browse_name"], ["Author (sorted by title)", "name_title"], ["Call number (browse)", "browse_cn"]] }
  let(:blacklight_configuration_context) { Blacklight::Configuration::Context.new(blacklight_controller) }

  before do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
    allow(view).to receive(:presenter).and_return(presenter)
    allow(view).to receive(:search_action_path).and_return("/catalog/suggest")
    allow(view).to receive(:search_fields).and_return(search_fields)
    render
  end

  it 'search aria label' do
    expect(rendered).to have_selector('#search_field[aria-label="Targeted search options"]')
  end
end
