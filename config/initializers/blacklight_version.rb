# frozen_string_literal: true

module Orangelight
  # TODO: Delete this method after we migrate to Blacklight 8
  def self.using_blacklight7?
    @using_blacklight7 ||= Gem.loaded_specs['blacklight'].version.to_s.start_with? '7'
  end
end
