# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'shared/_footer' do
  it 'renders a footer' do
    render
    # Lux does not render in the context of this test, so just checking for element
    expect(rendered).to include('lux-library-footer')
  end
end
