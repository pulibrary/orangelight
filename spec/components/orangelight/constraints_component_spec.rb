# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::ConstraintsComponent, type: :component do
  let(:params) do
    {
      action: 'index', controller: 'catalog',
      q1: 'dogs', f1: 'title',
      op2: 'not', q2: 'cats', f2: 'title',
      op3: '', q3: '', f3: ''
    }
  end
  let(:search_state) { Blacklight::SearchState.new(params, Blacklight::Configuration.new) }
  let(:component) { described_class.new(search_state:) }

  describe '#remove_guided_query_path' do
    it 'generates a valid path for removing guided search queries' do
      render_inline(component)
      expect(component.remove_guided_query_path(1)).to eq(
        '/?f2=title&f3=&op2=not&op3=&q2=cats&q3='
      )
    end
  end
  describe 'advanced search query constraints' do
    let(:rendered) { Capybara::Node::Simple.new(render_inline(component).to_s) }
    it 'includes constraints for non-empty search params' do
      expect(rendered).to have_selector('.applied-filter.constraint', text: 'Title: dogs')
      expect(rendered).to have_selector('.applied-filter.constraint', text: 'Title: NOT cats')
      expect(rendered).to have_selector('.applied-filter.constraint', count: 2)
    end
  end
end
