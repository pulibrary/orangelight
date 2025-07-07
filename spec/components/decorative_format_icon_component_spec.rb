# frozen_string_literal: true

require "rails_helper"

RSpec.describe DecorativeFormatIconComponent, type: :component do
  it 'displays an icon for Video/Projected medium' do
    rendered = render_inline described_class.new('Video/Projected medium')
    expect(rendered.css('svg').length).to eq 1
  end

  it 'does not display any icon for a non-existant format' do
    rendered = render_inline described_class.new('eqhfauirsohfbi3wubwesf')
    expect(rendered.css('svg')).to be_empty
  end

  it 'includes aria-hidden' do
    rendered = render_inline described_class.new('Video/Projected medium')
    expect(rendered.css('svg[aria-hidden = "true"]').length).to eq 1
  end
end
