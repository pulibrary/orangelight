# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Orangelight::MetadataFieldComponent, type: :component do
  it 'allows a custom label' do
    field = instance_double(Blacklight::FieldPresenter, render_field?: true, render: ['My value'], key: 'field')
    component = described_class.new(field:, labeler: ->(_show, _field) { 'My favorite field' })
    rendered = render_inline component

    expect(rendered.text).to include 'My favorite field'
  end
end
