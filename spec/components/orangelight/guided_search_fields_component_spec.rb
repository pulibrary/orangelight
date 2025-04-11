# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::GuidedSearchFieldsComponent, type: :component, advanced_search: true do
  subject(:render) do
    component.render_in(view_context)
  end
  let(:component) { described_class.new }

  let(:response) do
    Blacklight::Solr::Response.new({}.with_indifferent_access, {})
  end

  let(:rendered) do
    Capybara::Node::Simple.new(render)
  end

  let(:view_context) { vc_test_controller.view_context }

  before do
    render
  end

  it 'can calculate key value pairs for advanced search fields' do
    expect(component.advanced_key_value).to contain_exactly(["Keyword", "all_fields"], ["Title", "title"], ["Author/Creator", "author"], ["Subject", "subject"], ["Title starts with", "left_anchor"], ["Publisher", "publisher"], ["Notes", "notes"], ["Series title", "series_title"], ["ISBN", "isbn"], ["ISSN", "issn"])
  end

  describe '#guided_field' do
    before do
      controller.params[:clause] = { '0' => { 'field' => 'title' } }
      render
    end
    context 'when field_num is :clause_0_field' do
      it 'can get the field name from params clause[0][field]' do
        expect(component.guided_field(:clause_0_field, 'all_fields')).to eq('title')
      end
    end
  end

  describe '#label_tag_default_for' do
    context 'when key is :q1' do
      before do
        controller.params[:q] = 'cats'
        controller.params[:search_field] = 'all_fields'
        render
      end
      it 'takes search term from q param' do
        expect(component.label_tag_default_for(:q1)).to eq('cats')
      end
    end
    context 'when key is :clause_0_query' do
      before do
        controller.params[:q] = 'cats'
        controller.params[:search_field] = 'all_fields'
        render
      end
      it 'takes search term from q param' do
        expect(component.label_tag_default_for(:clause_0_query)).to eq('cats')
      end
    end
    context 'with a clause param' do
      before do
        controller.params[:clause] = { '0' => { 'field' => 'all_fields', 'query' => 'beasts' } }
        render
      end
      it 'takes search term from q param' do
        expect(component.label_tag_default_for(:clause_0_query)).to eq('beasts')
      end
    end
  end
end

def controller
  # ViewComponent 2.x
  return super if defined?(super)

  # ViewComponent 3.x
  return vc_test_controller if defined?(vc_test_controller)

  ApplicationController.new.extend(Rails.application.routes.url_helpers)
end
