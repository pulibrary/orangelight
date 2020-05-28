# Preview all emails at http://localhost:3000/rails/mailers/request_mailer
class RequestMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/request_mailer/pagingabc
  def on_shelf_email
    user_info =  {     
        "user_name" => "Foo Request",
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
            "pickup" => "PA"
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
          requestable: requestable,
          bib: bib
        }
    Requests::RequestMailer.on_shelf_email(Requests::Submission.new(params))
  end

end
