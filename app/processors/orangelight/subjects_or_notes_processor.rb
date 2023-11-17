# frozen_string_literal: true

module Orangelight
  class SubjectsOrNotesProcessor < Blacklight::Rendering::AbstractStep
    def render
      return next_step(values) unless context.action_name == 'index'

      em_sub_or_note = values.map do |value|
        if config.field == 'lc_subject_display'
          value if document.highlight_field('lc_subject_display')&.present? && Flipflop.highlighting?
        elsif config.field == 'notes_display'
          value if document.highlight_field('lc_subject_display')&.empty? && Flipflop.highlighting?
        else
          value
        end
      end
      next_step(em_sub_or_note.compact)
    end
  end
end
