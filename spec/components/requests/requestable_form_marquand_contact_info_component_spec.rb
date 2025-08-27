# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::RequestableFormMarquandContactInfoComponent, :requests, type: :component do
  it 'includes the title of the item in the mailto link' do
    with_controller_class Requests::FormController do
      requestable = double(Requests::Requestable)
      item = Requests::Item.new({ 'barcode' => '32101032980649' })
      allow(requestable).to receive_messages(preferred_request_id: '23490315030006421', item:, title: 'Das druckgraphische Werk von Matthaeus Merian d. Ae.')
      component = described_class.new(requestable:, single_item_request: false)
      rendered = render_inline component

      expected_subject = 'Requesting item in use'
      expected_body = 'Hello, could I please use the title Das druckgraphische Werk von Matthaeus Merian d. Ae. (barcode 32101032980649)?'
      expect(rendered.css('a').attribute('href').value).to include('mailto:marquand@princeton.edu')
      expect(rendered.css('a').attribute('href').value).to include(URI.encode_uri_component(expected_subject))
      expect(rendered.css('a').attribute('href').value).to include(URI.encode_uri_component(expected_body))
    end
  end
  it 'says Item In Use if item is LOAN' do
    with_controller_class Requests::FormController do
      requestable = double(Requests::Requestable)
      item = Requests::Item.new({ 'barcode' => '32101032980649', 'process_type' => 'LOAN' })
      allow(requestable).to receive_messages(preferred_request_id: '23490315030006421', item:, title: 'Das druckgraphische Werk von Matthaeus Merian d. Ae.')
      component = described_class.new(requestable:, single_item_request: false)
      rendered = render_inline component

      expect(rendered.text).to include('Item in use')
    end
  end
  it 'says Item Unavailable if item is not LOAN' do
    with_controller_class Requests::FormController do
      requestable = double(Requests::Requestable)
      item = Requests::Item.new({ 'barcode' => '32101032980649', 'process_type' => 'MISSING' })
      allow(requestable).to receive_messages(preferred_request_id: '23490315030006421', item:, title: 'Das druckgraphische Werk von Matthaeus Merian d. Ae.')
      component = described_class.new(requestable:, single_item_request: false)
      rendered = render_inline component

      expect(rendered.text).to include('Item unavailable')
    end
  end
end
