# frozen_string_literal: true
class NumismaticsFormSearchBuilder < SearchBuilder
  self.default_processor_chain += %i[fetch_configured_facets do_not_limit_configured_facets ensure_format_coin_is_the_only_fq]

  def fetch_configured_facets(solr_params)
    solr_params['facet.field'] = facet_config
  end

  def do_not_limit_configured_facets(solr_params)
    # -1 means do not limit
    limit_configuration = facet_config.to_h { |field| ["f.#{field}.facet.limit", '-1'] }
    solr_params.merge! limit_configuration
  end

  # :reek:UtilityFunction
  def ensure_format_coin_is_the_only_fq(solr_params)
    # We want a fq of format:Coin, so that we only fetch facet values relevant to numismatics
    # We don't want any other fq, since those would restrict the facet values and counts displayed
    # on the screen to only those relevant to the supplied fq, meaning that a user would not have
    # the opportunity to broaden their search
    solr_params[:fq] = ['format:Coin']
  end

  private

    def facet_config
      blacklight_config.numismatics_search[:facet_fields]
    end
end
