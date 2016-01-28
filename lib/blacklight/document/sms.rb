# -*- encoding : utf-8 -*-
# This module provides the body of an email export based on the document's semantic values
module Blacklight::Document::Sms

  # Return a text string that will be the body of the email
  def to_sms_text
    body = ''
    body << "Call Number: #{self['call_number_display'].uniq.join(', ')}" if self['call_number_display']
    body
  end

end
