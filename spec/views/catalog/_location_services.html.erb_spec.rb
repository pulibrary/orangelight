require 'rails_helper'

RSpec.describe 'catalog/_location_services.html.erb' do
  let(:classes) { 'service-conditional' }
  let(:holding_id) { '3668455' }
  let(:link) { '<a title="View Options to Request copies from this Location" class="request btn btn-xs btn-primary" data-toggle="tooltip" href="/requests/123456?mfhd=3668455&amp;source=pulsearch">Request</a>' }
  let(:open) { false }
  let(:requestable) { true }
  let(:aeon) { false }

  before do
    render(partial: 'location_services',
           locals: {
             classes: classes,
             holding_id: holding_id,
             link: link.html_safe,
             open: open,
             requestable: requestable,
             aeon: aeon
           })
  end

  it 'generates the markup containing the <div> container, data attributes, and the request link' do
    expect(rendered).to include '<div class="location-services service-conditional"'
    expect(rendered).to include 'data-open="false"'
    expect(rendered).to include 'data-requestable="true"'
    expect(rendered).to include 'data-aeon="false"'
    expect(rendered).to include 'data-holding-id="3668455"'
    expect(rendered).to include '<a title="View Options to Request copies from this Location"'
    expect(rendered).to include 'href="/requests/123456?mfhd=3668455&amp;source=pulsearch"'
  end
end
