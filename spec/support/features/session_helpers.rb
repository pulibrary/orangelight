# frozen_string_literal: true

module Features
  # Provides methods for login and logout within Feature Tests
  module SessionHelpers
    include Warden::Test::Helpers
  end
end
