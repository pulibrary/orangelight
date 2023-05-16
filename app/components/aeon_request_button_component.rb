# frozen_string_literal: true

# ViewComponent that displays an aeon request button on the show page
class AeonRequestButtonComponent < RequestButtonComponent
  def initialize(document:, holding: nil)
    @document = document
    @holding = holding
  end

  def label
    'Reading Room Request'
  end

  def tooltip
    'Request to view in Reading Room'
  end

  def url
    Requests::AeonUrl.new(document: @document, holding: @holding).to_s
  end
end
