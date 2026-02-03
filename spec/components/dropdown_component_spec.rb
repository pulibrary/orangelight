# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Orangelight::DropdownComponent, type: :component do
  let(:action_struct) { Struct.new(:label, :path, :partial) }
  let(:actions) do
    [
      action_struct.new('Email', '/email', 'bookmarks/document_action'),
      action_struct.new('Print', '/print', 'bookmarks/document_action')
    ]
  end

  it 'renders the dropdown with label: Export' do
    render_inline(described_class.new(label: 'Export', actions: actions))
    expect(page).to have_selector('button', text: 'Export')
  end

  it 'renders all actions as dropdown items' do
    render_inline(described_class.new(label: 'Export', actions: actions))
    actions.each do |action|
      expect(page).to have_link(action.label, href: action.path)
    end
  end
end
