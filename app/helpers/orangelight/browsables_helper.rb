module Orangelight::BrowsablesHelper
  def should_check_availability?(bib_id)
    bib_for_availability(bib_id) == bib_id
  end
  def bib_for_availability(bib_id)
    bib_id.to_i.to_s
  end
end
