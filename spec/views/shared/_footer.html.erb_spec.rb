# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_footer' do
  it 'renders a footer' do
    render
    expect(rendered).to match(//)
  end
end
