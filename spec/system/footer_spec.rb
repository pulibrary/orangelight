# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'the shared footer', type: :system, js: true do
  it 'renders the footer' do
    visit '/'
    expect(page).to have_link('Accessibility Help')
    expect(page).to have_selector('.lux-library-logo')
    expect(page).to have_link('For Library Staff')
  end
end
