# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/form/no_location_specified.html.erb', requests: true do
  it 'includes a link back to the record' do
    assign(:system_id, '9922486553506421')
    render
    expect(rendered).to have_selector('a[href="/catalog/9922486553506421"]')
  end
end
