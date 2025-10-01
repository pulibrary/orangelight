# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/request_mailer/on_shelf_confirmation.html.erb', type: :view, requests: true do
  let(:valid_patron_response) { file_fixture('../bibdata_patron_response.json') }

  let(:user_info) do
    stub_request(:get, "#{Requests.config[:bibdata_base]}/patron/foo?ldap=true").to_return(status: 200, body: valid_patron_response, headers: {})
    user = FactoryBot.create(:user, uid: 'foo')
    Requests::Patron.new(user:)
  end

  let(:requestable) do
    [
      {
        "selected" => "true",
        "mfhd" => "22251138630006421",
        "call_number" => "PS3566.I428 A6 2015",
        "location_code" => "firestone$stacks",
        "item_id" => "23251138620006421",
        "barcode" => "32101096297443",
        "copy_number" => "1",
        "status" => "Not Charged",
        "type" => "on_shelf",
        "pick_up" => "PA"
      }.with_indifferent_access,
      {
        "selected" => "false"
      }.with_indifferent_access
    ]
  end

  let(:bib) do
    {
      "id" => "9992220243506421",
      "title" => "This angel on my chest : stories",
      "author" => "Pietrzyk, Leslie"
    }.with_indifferent_access
  end

  let(:params) do
    {
      request: user_info,
      requestable:,
      bib:
    }
  end

  let(:submission) do
    Requests::Submission.new(params, user_info)
  end

  before do
    stub_delivery_locations
    assign(:submission, submission)
    render
  end

  it 'maintains correct DOM order of sections' do
    doc = Nokogiri::HTML(rendered)
    rows = doc.css('tr')

    header_index = rows.find_index { |row| row['class']&.include?('email-header') }
    body_index = rows.find_index { |row| row.text.include?(I18n.t('requests.on_shelf.email_conf_msg')) }
    pickup_index = rows.find_index { |row| row['class']&.include?('pickup-info') }
    bib_index = rows.find_index { |row| row['class']&.include?('bib-info') }

    expect(header_index).to be < body_index
    expect(body_index).to be < pickup_index
    expect(pickup_index).to be < bib_index
  end
end
