# frozen_string_literal: true

module Orangelight
  def read_only_mode
    @read_only_mode ||= ENV.fetch("OL_READ_ONLY_MODE", false) == "true"
  end

  def read_only_message
    default_msg = "Catalog is in read-only mode."
    @read_only_message ||= ENV.fetch("OL_READ_ONLY_MESSAGE", default_msg)
  end

  module_function :read_only_mode, :read_only_message
end
