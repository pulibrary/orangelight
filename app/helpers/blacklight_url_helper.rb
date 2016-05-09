module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  # adds the value and/or field to params[:f]
  # Does NOT remove request keys and otherwise ensure that the hash
  # is suitable for a redirect. See
  # add_facet_params_and_redirect
  def add_facet_params(field, item, source_params = params)
    field = item.field if item.respond_to? :field

    facet_config = facet_configuration_for_field(field)

    value = facet_value_for_facet_item(item)

    p = reset_search_params(source_params)
    p[:f] = (p[:f] || {}).dup # the command above is not deep in rails3, !@#$!@#$
    p[:f][field] = (p[:f][field] || []).dup

    p[:f][field] = [] if facet_config.single && !p[:f][field].empty?

    p[:f][field].push(value)
    p[:f][field].uniq!

    if item && item.respond_to?(:fq) && item.fq
      item.fq.each do |f, v|
        p = add_facet_params(f, v, p)
      end
    end

    p
  end
end
