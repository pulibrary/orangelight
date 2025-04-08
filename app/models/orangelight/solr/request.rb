# MAX START HERE!!!
class Orangelight::Solr::Request < Blacklight::Solr::Request
  def append_boolean_query(bool_operator, query)
    puts('IN Orangelight::Solr::Request#append_boolean_query')
    puts('---------------------------------------------------------------')
    return if query.blank?
    byebug
    # self[:json] ||= { query: { bool: { bool_operator => [] } } }
    self[:json] ||= { query: }

    self[:json][:query] ||= { }
    self[:json][:query][:edismax] ||= { }

    if self[:json][:query][:edismax]
      byebug
    end

    if self['q']
      self[:json][:query][:bool][:must] ||= []
      self[:json][:query][:bool][:must] << self['q']
      delete 'q'
    end

    self[:json][:query][:bool][bool_operator] << query
  end
end
