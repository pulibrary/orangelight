# frozen_string_literal: true

class FormatFieldComponent < Blacklight::MetadataFieldComponent
  def format_icon
    icon = helpers.render_icon(@field.values.first).to_s
    safe_join [icon, ' ', format_render]
  end

  def format_render
    @field.values.join(', ')
  end
end
