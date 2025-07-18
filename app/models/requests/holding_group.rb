# frozen_string_literal: true

# This class represents a group of physical holdings that
# are grouped together for display
class Requests::HoldingGroup
  include Comparable

  def initialize(group_name:, holdings:)
    @group_name = group_name
    @holdings = holdings
  end

  # rubocop:disable Lint/DuplicateBranch
  # :reek:DuplicateMethodCall
  def <=>(other)
    if firestone? && !other.firestone?
      -1 # Firestone should go first
    elsif !firestone? && other.firestone?
      1
    elsif off_site? && !other.off_site?
      1 # Off site locations should go last
    elsif !off_site? && other.off_site?
      -1
    else
      group_name <=> other.group_name
    end
  end
  # rubocop:enable Lint/DuplicateBranch

  def firestone?
    group_name.start_with? 'Firestone'
  end

  def off_site?
    group_name.start_with?('Annex', 'Forrestal') || group_name.include?('Remote Storage') || group_name.downcase.include?('(off-site)')
  end

  attr_reader :group_name, :holdings
end
