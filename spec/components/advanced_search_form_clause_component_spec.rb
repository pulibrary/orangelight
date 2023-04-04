# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdvancedSearchFormClauseComponent, type: :component do
  it "renders a select" do
    search_fields = [
      ['Keyword', 'all_fields'],
      ['Author', 'author']
    ]
    component = described_class.new(index: 0, default: 'all_fields', search_fields:)
    expect(Capybara::Node::Simple.new(render_inline(component))).to have_select 'clause_0_field', selected: 'Keyword'
  end
end
