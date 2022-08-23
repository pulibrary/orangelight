# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Requests::Submissions::Illiad do
  let(:user_info) do
    {
      "netid" => "jstudent",
      "barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }.with_indifferent_access
  end
  let(:patron) { Requests::Patron.new(user: {}, patron: user_info) }
  let(:requestable) do
    [
      {
        "selected" => "true",
        "mfhd" => "22113812720006421",
        "call_number" => "HA202 .U581",
        "location_code" => "recap$pa",
        "item_id" => "3059236",
        "delivery_mode_3059236" => "print",
        "barcode" => "32101044283008",
        "enum" => "2000 (13th ed.)",
        "copy_number" => "1",
        "status" => "Not Charged",
        "type" => "bd",
        "edd_start_page" => "",
        "edd_end_page" => "",
        "edd_volume_number" => "",
        "edd_issue" => "",
        "edd_author" => "",
        "edd_art_title" => "",
        "edd_note" => "",
        "pick_up" => "Firestone Library"
      },
      {
        "selected" => "false"
      }
    ]
  end
  let(:bib) do
    {
      "id" => "994916543506421",
      "title" => "County and city data book.",
      "author" => "United States",
      "date" => "1949",
      "isbn" => '9780544343757'
    }
  end
  let(:params) do
    {
      request: user_info,
      requestable: requestable,
      bib: bib
    }
  end

  let(:submission) do
    Requests::Submission.new(params, patron)
  end

  it 'runs a test' do
    expect(described_class.new(submission)).to be_an_instance_of(described_class)
  end
end
