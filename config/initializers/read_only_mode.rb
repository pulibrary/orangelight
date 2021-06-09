# frozen_string_literal: true

module Orangelight
  def read_only_mode
    @read_only_mode ||= ENV.fetch("ORANGELIGHT_READ_ONLY_MODE", false) == "true"
  end

  module_function :read_only_mode
end
