# frozen_string_literal: true
class RelaisBorrowDirectConstraint
  def matches?(_request)
    !Flipflop.reshare_for_borrow_direct?
  end
end
