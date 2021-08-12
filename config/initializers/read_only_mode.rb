# frozen_string_literal: true

module Orangelight
  def read_only_mode
    @read_only_mode ||= ENV.fetch("OL_READ_ONLY_MODE", false) == "true"
  end

  def read_only_message
    default_msg = "The Library Catalog is undergoing maintenance. Bookmarks, digitization requests, and saved searches are currently unavailable."
    @read_only_message ||= ENV.fetch("OL_READ_ONLY_MESSAGE", default_msg)
  end

  module_function :read_only_mode, :read_only_message
end

# Block database writes in read_only mode
if Orangelight.read_only_mode
  class ActiveRecord::Base
    before_save do
      raise ActiveRecord::Rollback, "Read-only"
    end

    before_destroy do
      raise ActiveRecord::Rollback, "Read-only"
    end
  end
end
