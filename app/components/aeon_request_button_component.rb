# frozen_string_literal: true

# ViewComponent that displays an aeon request button on the show page
class AeonRequestButtonComponent < RequestButtonComponent
  def initialize(document:, location:)
    @document = document
    @location = location
  end

  def label
    'Reading Room Request'
  end

  def tooltip
    'Request to view in Reading Room'
  end

  def url
    Requests::AeonUrl.new(document: @document).to_s
  end
end
