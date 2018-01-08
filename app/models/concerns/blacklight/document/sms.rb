# frozen_string_literal: true

# This module provides the body of an email export based on the document's semantic values
module Blacklight
  module Document
    module Sms
      # Return a text string that will be the body of the email
      def to_sms_text
        return '' unless self['call_number_display']
        "Call Number: #{self['call_number_display'].uniq.join(', ')}"
      end
    end
  end
end
