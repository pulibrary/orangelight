# frozen_string_literal: true

def format_label(key)
  label = key.to_s
  human_label = label.tr('_', ' ')
  formatted = human_label.split.map(&:capitalize).join(' ')
  formatted
end

def display_label
  {
    author: "Author/Artist",
    title: "Title",
    date: "Published/Created",
    id: "Bibliographic ID",
    mfhd: "Holding ID (mfhd)"
  }.with_indifferent_access
end

# Preview all emails at http://localhost:3000/rails/mailers/request_mailer
class RequestMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/request_mailer/on_shelf_email
  def on_shelf_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }

    User.create!(
      username: "Foo Request",
      email: "foo@princeton.edu",
      uid: "22101007797777",
      provider: "cas",
      password: "foobarfoo"
    )
    patron = preview_patron(user_info)
    Requests::RequestMailer.on_shelf_email(Requests::Submission.new(params, patron).to_h)
  end

  def on_shelf_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.on_shelf_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def in_process_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.in_process_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def in_process_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.in_process_email(Requests::Submission.new(params, patron).to_h)
  end

  def lewis_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.lewis_email(Requests::Submission.new(params, patron).to_h)
  end

  def on_order_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.on_order_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def on_order_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.on_order_email(Requests::Submission.new(params, patron).to_h)
  end

  def ppl_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.ppl_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def ppl_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.ppl_email(Requests::Submission.new(params, patron).to_h)
  end

  def pres_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.pres_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def pres_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.pres_email(Requests::Submission.new(params, patron).to_h)
  end

  def recap_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA",
          "delivery_mode_8298341" => "edd",
          "edd_art_title" => "my stuff",
          "edd_start_page" => "EDD Start Page",
          "edd_end_page" => "EDD End Page",
          "edd_volume_number" => "EDD Volume Number",
          "edd_issue" => "EDD Issue",
          "edd_author" => "EDD Author",
          "edd_note" => "EDD Note"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.recap_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def recap_no_items_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.recap_no_items_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def recap_no_items_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.recap_no_items_email(Requests::Submission.new(params, patron).to_h)
  end

  def annex_no_items_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.annex_no_items_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  def annex_no_items_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.annex_no_items_email(Requests::Submission.new(params, patron).to_h)
  end

  def service_error_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    submission = Requests::Generic.new(params)
    submission.errors << { :reply_text => "Can not create hold", :create_hold => { note: "Hold can not be created" }, "id" => "10574699", "title" => "Mefisto : rivista di medicina, filosofia, storia", "author" => "", "first_name" => "Foo Request", "last_name" => "Request", "user_barcode" => "0000000000", "patron_id" => "00000", "patron_group" => "REG", "email" => "foo@princeton.edu", "source" => "pulsearch" }
    Requests::RequestMailer.service_error_email([submission])
  end

  def trace_email
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.trace_email(Requests::Submission.new(params, patron).to_h)
  end

  def recap_edd_confirmation
    user_info = {
      "first_name" => "Foo Request",
      "last_name" => "Request",
      "user_barcode" => "22101007797777",
      "email" => "foo@princeton.edu",
      "source" => "pulsearch"
    }
    requestable =
      [
        {
          "selected" => "true",
          "mfhd" => "9533612",
          "call_number" => "TR465 .C666 2016",
          "location_code" => "pres",
          "item_id" => "3059236",
          "barcode" => "32101044283008",
          "copy_number" => "0",
          "status" => "Not Charged",
          "type" => "pres",
          "pick_up" => "PA"
        }.with_indifferent_access,
        {
          "selected" => "false"
        }.with_indifferent_access
      ]

    bib =
      {
        "id" => "9712355",
        "title" => "The atlas of water damage on inkjet-printed fine art /",
        "author" => "Connor, Meghan Burge, Daniel Rochester Institute of Technology"
      }
    params =
      {
        request: user_info,
        requestable:,
        bib:
      }
    patron = preview_patron(user_info)
    Requests::RequestMailer.recap_edd_confirmation(Requests::Submission.new(params, patron).to_h)
  end

  private

    def preview_user
      User.find_or_create_by!(
        username: "Foo Request",
        email: "foo@princeton.edu",
        uid: "22101007797777",
        provider: "cas"
      ) do |user|
        user.password = "foobarfoo"
      end
    end

    def preview_patron(user_info)
      Requests::Patron.new(user: preview_user, patron_hash: user_info)
    end
end
