# frozen_string_literal: true
# This module identifies spam bots based on them
# filling out a "honeypot" field.
module Honeypot
  attr_accessor :feedback_desc

    private

      def spam?
        # feedback_desc is a hidden field that is not presented
        # to human users.  If feedback_desc is present, it was almost
        # certainly filled in by a spam robot.
        feedback_desc.present?
      end
end
