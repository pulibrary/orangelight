# frozen_string_literal: true

require "rails_helper"

RSpec.describe Orangelight::System::FlashMessageComponent, type: :component do
  it 'can display a notice' do
    collection = ['Hello!  Welcome!']
    rendered = render_inline(described_class.with_collection(collection, type: 'notice'))

    lux_alert = rendered.css("lux-alert")

    expect(lux_alert.attribute("status").value).to eq 'info'
    expect(lux_alert.text).to eq 'Hello!  Welcome!'
  end
end
