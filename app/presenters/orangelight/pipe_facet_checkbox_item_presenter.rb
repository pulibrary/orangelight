# frozen_string_literal: true
class Orangelight::PipeFacetCheckboxItemPresenter < Blacklight::FacetCheckboxItemPresenter
  def label = super.gsub('|||', ' — ')
end
