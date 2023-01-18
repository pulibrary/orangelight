# frozen_string_literal: true

class Orangelight::ConstraintComponent < Blacklight::ConstraintComponent
  def constraint_value
    if old_style_params?
      @facet_item_presenter.constraint_label['0']
    elsif @facet_item_presenter.constraint_label.respond_to? :to_s
      @facet_item_presenter.constraint_label
    end
  end

  private

    def old_style_params?
      @facet_item_presenter.constraint_label.is_a?(ActiveSupport::HashWithIndifferentAccess) &&
        @facet_item_presenter.constraint_label.key?('0')
    end
end
