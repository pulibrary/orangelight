# frozen_string_literal: true

# This class represents a group of physical holdings that
# are grouped together for display
class Requests::HoldingGroup
  def initialize(group_name:, holdings:)
    @group_name = group_name
    @holdings = holdings
  end

  attr_reader :group_name, :holdings
end
