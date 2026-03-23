# frozen_string_literal: true

# This is a more flexible version of Blacklight's MetadataFieldComponent, allowing you to
# inject custom behavior for the labeler and whether or not to render
class Orangelight::MetadataFieldComponent < Blacklight::MetadataFieldComponent
  # :reek:BooleanParameter - it maintains compatibility with Blacklight::MetadataFieldComponent's API
  # :reek:LongParameterList
  # rubocop:disable Metrics/ParameterLists
  def initialize(
    field:, layout: nil, show: false, view_type: nil,
    labeler: ->(show, field) { show ? show_field_label(field.label('show')) : index_field_label(field.label) },
    should_render: ->(field) { field.render_field? }
  )
    super(field:, layout:, show:, view_type:)
    @labeler = labeler
    @should_render = should_render
  end
  # rubocop:enable Metrics/ParameterLists

  def label
    labeler.call(show, field)
  end

  def render?
    should_render.call(field)
  end

    private

      attr_reader :field, :labeler, :should_render, :show
end
