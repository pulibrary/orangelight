# frozen_string_literal: true

class CallNumberDocument < BrowseListDocument
  def title
    value = fetch(:title_s, nil)
    Array.wrap(value).first
  end

  def author
    value = fetch(:author_s, nil)
    Array.wrap(value).first
  end

  def date
    value = fetch(:date_s, nil)
    Array.wrap(value).first
  end

  def bibid
    value = fetch(:bibid_s, nil)
    Array.wrap(value).first
  end

  def holding_id
    value = fetch(:holding_id_s, nil)
    Array.wrap(value).first
  end

  def location
    value = fetch(:location_s, nil)
    Array.wrap(value).first
  end
end
