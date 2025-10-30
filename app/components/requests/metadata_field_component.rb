# frozen_string_literal: true

# This component is responsible for displaying metadata fields and values that are appropriate for
# the Requests form
class Requests::MetadataFieldComponent < Blacklight::MetadataFieldComponent
  def render?
    field.values.present? && !ridiculous_date?
  end

  private

    attr_reader :field

    def ridiculous_date?
      field.key == 'pub_date_display' && field.values.any? { it.to_i > 5000 }
    end
end
