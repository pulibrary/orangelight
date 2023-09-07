# frozen_string_literal: true
module Orangelight
  class ClausePresenter < Blacklight::ClausePresenter
    def label
      if user_parameters[:op] == 'must_not'
        "NOT #{super}"
      else
        super
      end
    end
  end
end
