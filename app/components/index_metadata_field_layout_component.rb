# frozen_string_literal: true

class IndexMetadataFieldLayoutComponent < ViewComponent::Base
  # :reek:UnusedParameters
  def initialize(field: nil); end

  renders_one :label
  # rubocop:disable Lint/UnusedBlockArgument -- index: is in the API provided by stock blacklight, we should keep the same API here
  renders_many :values, ->(index:, value: nil) { value }
  # rubocop:enable Lint/UnusedBlockArgument
end
