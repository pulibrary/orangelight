# frozen_string_literal: true
# This component is responsible for displaying a JSON hash as multiple fields
class HashMetadataFieldComponent < ViewComponent::Base
  def initialize(field_config:, solr_field_name:, document:, operations: Blacklight::Rendering::Pipeline.operations)
    @field_config = field_config
    @solr_field_name = solr_field_name
    @document = document
    @operations = operations
  end

    private

      attr_reader :field_config, :solr_field_name, :document, :operations

      def fields
        @fields ||= JSON.parse(document[solr_field_name])
      end

      def render_values(raw)
        Blacklight::Rendering::Pipeline.new(raw, field_config, document, controller.view_context, operations, {}).render
      end
end
