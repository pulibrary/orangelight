# frozen_string_literal: true

class IndexMetadataFieldLayoutComponent < ViewComponent::Base
  renders_one :label
  renders_many :values
end
