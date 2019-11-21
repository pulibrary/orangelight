# frozen_string_literal: true

class BrowseListDocument
  include Blacklight::Solr::Document

  def self.build_from_facet(model_name:, facet:, index:)
    {
      id: facet,
      model_s: model_name,
      index_i: index,
      normalized_sort: facet.normalize_em,
      direction_s: facet.dir
    }
  end

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
