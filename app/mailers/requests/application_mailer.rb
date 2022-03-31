# frozen_string_literal: true
module Requests
  class ApplicationMailer < ActionMailer::Base
    default from: "lsupport@princeton.edu"
    layout "requests/mailer"
  end
end
