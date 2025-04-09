class Orangelight::Solr::Request < Blacklight::Solr::Request
  def append_boolean_query(bool_operator, query)
    puts('IN Orangelight::Solr::Request#append_boolean_query')
    puts('---------------------------------------------------------------')
    return if query.blank?

    self[:json] ||= { query: { bool: { bool_operator => [] } } }
    self[:json][:query] ||= { bool: { bool_operator => [] } }
    self[:json][:query][:bool][bool_operator] ||= []

    if self['q']
      self[:json][:query][:bool][:must] ||= []
      self[:json][:query][:bool][:must] << self['q']
      delete 'q'
    end

    self[:json][:query][:bool][bool_operator] << query
  end
end
