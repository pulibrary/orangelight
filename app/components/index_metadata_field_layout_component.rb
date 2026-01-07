# frozen_string_literal: true

class IndexMetadataFieldLayoutComponent < ViewComponent::Base
  # :reek:UnusedParameters
  def initialize(field: nil); end

  renders_one :label
  renders_many :values, ->(index:, value: nil) { value }
end
