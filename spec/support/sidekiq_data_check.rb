# frozen_string_literal: true
# This class is responsible for checking whether a provided data structure
# is compatible with sidekiq.
#
# See https://github.com/sidekiq/sidekiq/wiki/Best-Practices#1-make-your-job-parameters-small-and-simple
class SidekiqDataCheck
  include Sidekiq::JobUtil
  def initialize(data_to_check)
    @data_to_check = { "args" => data_to_check }
  end

  def valid?
    check
    true
  rescue ArgumentError
    false
  end

  def error_message
    check
  rescue ArgumentError => e
    e.message
  end

  private

    attr_reader :data_to_check

    # Returns nil if valid, raises ArgumentError if not
    def check
      Sidekiq::Config::DEFAULTS[:on_complex_arguments] = :raise
      verify_json data_to_check
    end
end

RSpec::Matchers.define :be_compatible_with_sidekiq do
  match { |actual| SidekiqDataCheck.new(actual).valid? }
  failure_message { |actual| SidekiqDataCheck.new(actual).error_message }
end
