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

    # We will no longer need to override #field_label when/if we
    # use a release of Blacklight that includes
    # https://github.com/projectblacklight/blacklight/pull/3442
    def field_label
      field_config&.display_label('search')
    end
  end
end
