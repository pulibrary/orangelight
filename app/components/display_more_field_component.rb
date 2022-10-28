# frozen_string_literal: true

class DisplayMoreFieldComponent < Blacklight::MetadataFieldComponent
  def show_more_text
    additional_item_count = @field.values.length - @field.field_config.maxInitialDisplay
    t('blacklight.show_page.display_more', count: additional_item_count, field: @field.label)
  end

  def show_button?
    @field.values.length > @field.field_config.maxInitialDisplay
  end
end
