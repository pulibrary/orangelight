# frozen_string_literal: true

# This component is responsible for displaying a compact badge
# with the text and icon of a resource's format
class FormatBadgeFieldComponent < Blacklight::MetadataFieldComponent
  delegate :deduplication?, to: Flipflop
  def online_color
    deduplication? ? 'purple' : 'blue'
  end
end
