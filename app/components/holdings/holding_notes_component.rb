# frozen_string_literal: true
# This component is responsible for rendering holdings-level notes
class Holdings::HoldingNotesComponent < ViewComponent::Base
  def initialize(holding, holding_id, adapter)
    @holding = holding
    @holding_id = holding_id
    @adapter = adapter
  end

    private

      attr_reader :holding, :holding_id, :adapter

      def render_shelving_titles?
        adapter.shelving_title?(holding)
      end

      def render_location_notes?
        adapter.location_note?(holding)
      end

      def render_location_has?
        adapter.location_has?(holding)
      end

      def render_supplements?
        adapter.supplements?(holding)
      end

      def render_indexes?
        adapter.indexes?(holding)
      end

      def render_issues?
        adapter.journal?
      end

      # :reek:TooManyStatements
      # :reek:NestedIterators
      # :reek:FeatureEnvy
      def render_list(label:, list_class:, notes:)
        render HoldingNoteListComponent.new do |component|
          component.with_label { label }
          component.with_list_class { list_class }
          notes&.each do |note|
            component.with_note { note }
          end
        end
      end

      def doc_id
        holding["mms_id"] || adapter.doc_id
      end

      # This private class is responsible for displaying a list of
      # notes.  It is used for many types of notes that all have the
      # same DOM structure and style.
      class HoldingNoteListComponent < ViewComponent::Base
        renders_one :label
        renders_one :list_class
        renders_many :notes

        erb_template <<~END_TEMPLATE
          <ul class="<%= list_class %>">
            <li class="holding-label"><%= label %></li>
            <% notes.each do |note| %>
              <li><lux-show-more v-bind:character-limit="150" show-label="See more" hideLabel="See less"><%= note %></lux-show-more></li>
            <% end %>
          </ul>
        END_TEMPLATE
      end
end
