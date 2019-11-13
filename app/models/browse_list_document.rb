# frozen_string_literal: true

class BrowseListDocument
  include Blacklight::Solr::Document

  def label
    fetch(:id, nil)
  end

  def index
    fetch(:index_i, nil)
  end

  def count
    fetch(:count_i, nil)
  end

  def sort
    value = fetch(:normalized_s, nil)
    Array.wrap(value).first
  end
  alias normalized sort

  def dir
    fetch(:direction_s, nil)
  end
  alias direction dir
end
