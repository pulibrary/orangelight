# Search Algorithm Switching

As part of the Search and Race project work, we've decided to explore allowing users to execute their catalog search queries using alternative algorithms used for querying Apache Solr as well as for ranking the search results.

## Technical Implementation

### Apache Solr Request Handler

_(Please refer to [the documentation](https://solr.apache.org/guide/solr/latest/configuration-guide/requesthandlers-searchcomponents.html#RequestHandlersandSearchComponentsinSolrConfig-RequestHandlers) for this component of Apache Solr.)_

In order to provide support at the level of the SolrCloud deployment for the
Princeton University Library, one must please first focus upon proposing changes
for the [PUL Solr](https://github.com/pulibrary/pul_solr) GitHub repository.

An example of this may be found within the
[solrconfig.xml](https://github.com/pulibrary/pul_solr/blob/main/solr_configs/catalog-production-v2/conf/solrconfig.xml)
for the SolrCloud Collection. In this case, the `requestHandler`
`engineering_search` was added, however, for the purposes of this document, the
example name `alternative-search` shall be used:

```xml
  <requestHandler name="alternative-search" class="solr.SearchHandler" initParams="searchParams">
    <!-- Appends means we add this parameter always but the query sent by the client can also add more of them. -->
    <lst name="appends">
      <str name="boost">if(termfreq(text,'engineering'),100,0)</str>
    </lst>
  </requestHandler>
```

The attribute `initParams` refers to a set of initial parameters passed to the
`requestHandler` constructed within Apache Solr, and this is also found within
the `solrconfig.xml`. With regards to the syntax of these query configuration
values, please reference [the documentation describing the Solr standard query parser](https://solr.apache.org/guide/solr/latest/query-guide/standard-query-parser.html).

```xml
  <initParams name="searchParams">
    <!-- default values for query parameters can be specified, these
         will be overridden by parameters in the request
      -->
    <lst name="defaults">
      <str name="defType">edismax</str>
      <str name="echoParams">explicit</str>
      <int name="rows">10</int>
      <str name="sow">on</str>
      <str name="q.alt">*:*</str>
      <str name="mm">6&lt;90%</str>

      <!-- HighlightComponent using unified highlighter -->
      <str name="hl">true</str>
      <str name="hl.method">unified</str>
      <str name="hl.fl">author_display title_display title_vern_display</str>

      <!-- boost local holdings (add 50 to the score) to reduce unnecessary requests -->
      <str name="bf">if(field(numeric_id_b),50,0)</str>

       <!-- this qf and pf are used by default, if not otherwise specified by
            client. The default blacklight_config will use these for the
            "keywords" search. See the author_qf/author_pf, title_qf, etc
            below, which the default blacklight_config will specify for
            those searches. You may also be interested in:
            http://wiki.apache.org/solr/LocalParams
       -->

      <str name="qf">
        title_a_index^1500
        author_main_unstem_search^1000
        title_unstem_search^40
        title_display^40
        author_unstem_search^40
        subject_topic_unstem_search^18
        subject_unstem_search^15
        siku_subject_unstem_search^15
        local_subject_unstem_search^15
        homoit_subject_unstem_search^15
        subject_topic_index^12
        genre_unstem_search^10
        subject_t^10
        subject_addl_unstem_search^8
        subject_addl_t^4
        isbn_t^3
        issn_s^3
        lccn_s^3
        uncontrolled_keyword_unstem_search^3
        text
        description_t
        cjk_all
        cjk_text
      </str>
      <str name="pf">
        title_245a_lr^16000
        title_245_lr^16000
        title_a_index^12000
        author_main_unstem_search^10000
        title_unstem_search^400
        title_display^400
        author_unstem_search^400
        subject_topic_unstem_search^180
        subject_unstem_search^150
        siku_subject_unstem_search^150
        local_subject_unstem_search^150
        homoit_subject_unstem_search^150
        subject_topic_index^120
        genre_unstem_search^100
        subject_t^100
        subject_addl_unstem_search^80
        subject_addl_t^40
        isbn_t^30
        issn_s^30
        lccn_s^30
        uncontrolled_keyword_unstem_search^10
        text^10
        description_t^10
        cjk_all^10
        cjk_text^10
      </str>
      <str name="author_qf">
        author_main_unstem_search^20
        author_unstem_search^10
        cjk_author
      </str>
      <str name="author_pf">
        author_main_unstem_search^200
        author_unstem_search^100
        cjk_author^10
      </str>
      <str name="left_anchor_qf">
        title_245a_la^50
        title_245_la^10
        title_la^2
        title_addl_la
      </str>
      <str name="left_anchor_pf">
        title_245a_lr^600
        title_245_lr^600
        title_245a_la^500
        title_245_la^100
        title_lr^100
        title_la^20
        title_addl_la^10
      </str>
      <str name="in_series_qf">
        more_in_this_series_la
      </str>
      <str name="in_series_pf">
        more_in_this_series_la
      </str>
      <str name="publisher_qf">
        pub_created_unstem_search
        cjk_publisher
      </str>
      <str name="publisher_pf">
        pub_created_unstem_search
        cjk_publisher
      </str>
      <str name="notes_qf">
        notes_index
        cjk_notes
        cjk_notes_copied
      </str>
      <str name="notes_pf">
        notes_index
        cjk_notes
        cjk_notes_copied
      </str>
      <str name="series_title_qf">
        series_title_index^5
        series_ae_index
        series_statement_index
        linked_series_title_index
        linked_series_index
        original_version_series_index
        cjk_series_title
      </str>
      <str name="series_title_pf">
        series_title_index^50
        series_ae_index^10
        series_statement_index^10
        linked_series_title_index^10
        linked_series_index^10
        original_version_series_index^10
        cjk_series_title^10
      </str>
      <str name="title_qf">
        title_a_index^500
        title_unstem_search^100
        title_display^50
        other_title_index^5
        series_title_index^5
        uniform_title_s^5
        title_vern_display
        content_title_index
        contains_title_index
        linked_title_index
        series_ae_index
        series_statement_index
        linked_series_title_index
        linked_series_index
        original_version_series_index
        cjk_title
      </str>
      <str name="title_pf">
        title_245a_lr^5500
        title_245_lr^5500
        title_a_index^5000
        title_unstem_search^1000
        title_display^500
        other_title_index^50
        series_title_index^50
        uniform_title_s^50
        title_vern_display^10
        content_title_index^10
        contains_title_index^10
        linked_title_index^10
        series_ae_index^10
        series_statement_index^10
        linked_series_title_index^10
        linked_series_index^10
        original_version_series_index^10
        cjk_title^10
      </str>
      <str name="subject_qf">
        subject_topic_unstem_search^25
        subject_unstem_search^20
        genre_unstem_search^15
        siku_subject_unstem_search
        local_subject_unstem_search
        homoit_subject_unstem_search
        cjk_subjec
      </str>
      <str name="subject_pf">
        subject_topic_unstem_search^250
        subject_unstem_search^200
        genre_unstem_search^150
        siku_subject_unstem_search^10
        local_subject_unstem_search^10
        homoit_subject_unstem_search^10
        cjk_subject^10
      </str>

      <int name="ps">3</int>
      <float name="tie">0.01</float>

      <str name="fl">
        id,
        score,
        author_display,
        marc_relator_display,
        format,
        pub_created_display,
        title_display,
        title_vern_display,
        isbn_s,
        oclc_s,
        lccn_s,
        holdings_1display,
        electronic_access_1display,
        electronic_portfolio_s,
        cataloged_tdt,
        contained_in_s
      </str>

      <str name="facet">true</str>
      <str name="facet.mincount">1</str>
      <str name="facet.limit">10</str>
      <str name="facet.field">format</str>
      <str name="facet.field">language_facet</str>
      <str name="facet.field">pub_date_start_sort</str>
      <str name="facet.field">advanced_location_s</str>
      <str name="f.format.facet.sort">index</str>
      <str name="f.advanced_location_s.facet.sort">index</str>
      <str name="f.language_facet.facet.limit">1000</str>
      <str name="f.advanced_location_s.facet.limit">500</str>
    </lst>
  </initParams>
```

In order to further extend the default parameters sent within HTTP requests to
Solr, one need not directly modify the `initParams`, but instead override by following this pattern:

```xml
    <lst name="appends">
      <str name="boost">if(termfreq(text,'engineering'),100,0)</str>
    </lst>
```

In this case, `<lst>` specifies the list of parameters to send in the request,
and the attribute `appends` qualifies the the child elements are to be appended
to the `<lst>` elements specified within the `initParams`. The `<str>` encodes a parameter used for boosting search results by certain criteria (hence the `name="boost"`). The function query `if(termfreq(text, 'engineering'),100,0)` determines if the `text` field contains the string `engineering`, and if so, boosts the weight of the result by 100. If it does not contain `engineering`, it boosts the weight by 0.For more information, please referencing the [Solr documentation specific to configuring request handlers](https://solr.apache.org/guide/solr/latest/configuration-guide/requesthandlers-searchcomponents.html#defaults-appends-and-invariants).

#### Submitting Proposed Changes

Please proceed at this point with opening a pull request and requesting a review
of the updated `ConfigSet`. An example of this can be found within the
following:

- https://github.com/pulibrary/pul_solr/pull/375
- https://github.com/pulibrary/pul_solr/pull/377

#### Deploying

One must then deploy the updated `SolrConfig` settings using [Capistrano](https://capistranorb.com/) with the following:

```bash
$ bundle exec cap staging deploy
$ bundle exec cap staging configsets:update[orangelight-staging/conf,orangeligh-staging-config]"
```

Please reference the [PUL Solr documentation](https://github.com/pulibrary/pul_solr#managing-configsets) for further guidance regarding the updating of Solr `ConfigSets`.

### Integration with Blacklight

One may integrate support for switching the search algorithms by following the
reference implementation undertaken by Group 1 of the Search and Race initiative
for Orangelight:

- https://github.com/pulibrary/orangelight/pull/3813
- https://github.com/pulibrary/orangelight/pull/3819
- https://github.com/pulibrary/orangelight/pull/3827

#### Copying the Solr Configuration

Before any other steps, please copy Solr configuration settings introduced into `pul_solr` earlier into the local Blacklight application. This should
ensure that the file `solr/conf/solrconfig.xml` contains the same alternative `requestHandler` and `initParams` elements which were implemented earlier.

#### Feature Flipping with Flip-Flop

First, please add and integrate the [Flip-Flop Gem](https://rubygems.org/gems/flipflop/) with the following:

```bash
bundle add flipflop
bundle exec rails generate flipflop:install
bundle exec rails db:migrate
```

Then, create the file `config/features.rb`, and please add the following:
```ruby
 group :alternative_search do
    feature :multi_algorithm,
      default: false,
      description: "When on / true, the user will have the ability to choose between search algorithms.  When off / false, no choice is available"
```

#### Custom SearchBuilder

One must then implement a custom `SearchBuilder` within `app/models/alternative_search_builder.rb` with the following, where `alternative-search` matches the name of the Solr `requestHandler` which was implemented previously:

```ruby
class AlternativeSearchBuilder < SearchBuilder
  self.default_processor_chain += [:switch_request_handler]

  def switch_request_handler(solr_parameters)
    solr_parameters[:qt] = "alternative-search"
  end
end
```

#### CatalogController

##### Modifying the Blacklight configuration

One must first extend the functionality of the `CatalogController` with a number
of new methods. A valid approach would be to utilize a mixin by implementing a
new `Module` within a new file `app/controllers/concerns/multiples_algorithms.rb`:

```ruby
module MultipleAlgorithms
  class << self
    # When adding a new Ranking Algorithm the name will need to be added to this variable before it can be utilized.
    # For example if you added a cats ranking algorithm, with a CatsSearchBuilder you would set this variable
    # in the catalog controller and add "cats" to the list  `MultipleAlgorithms.allowed_search_algorithms = ["default", "cats"]`
    # This is to make sure the user can not just execute any SearchBuilder in the system.
    attr_accessor :allowed_search_algorithms
  end

  def search_service_context
    return {} unless Pulfalight.multiple_algorithms_enabled?
    return {} unless alternate_search_builder_class # use default if none specified
    { search_builder_class: alternate_search_builder_class }
  end

  def alternate_search_builder_class
    return unless search_algorithm_param && MultipleAlgorithms.allowed_search_algorithms.include?(search_algorithm_param)

    "#{search_algorithm_param}_search_builder".camelize.constantize
  end

  def search_algorithm_param
    params[:search_algorithm]
  end
end
```

One would then integrate this into the `CatalogController` by adding this below
the initial `include` statements nearest to the initial line declaring the
class:
```ruby
class CatalogController < ApplicationController
  [...]
  include MultipleAlgorithms
  [...]
end
```

##### Modifying the Blacklight configuration

This is then integrated into the `CatalogController` with the following within
the `configure_blacklight` block near the nearest
`config.add_results_collection_tool` line:

```ruby
  configure_blacklight do |config|
      # [...]
      config.add_results_collection_tool(:algorithm_select)
      # [...]
  end
```

Please note that the ordering of the lines `config.add_results_collection_tool`
determines the ordering of these UI components within the page.

#### Blacklight View Component Implementation

One must then implement a new Blacklight View Component in order to extend the
UI for enabling and disabling the alternative search algorithm by implementing
the following within `app/components/dropdown_help_text_component.rb`:

```ruby
class DropdownHelpTextComponent < Blacklight::System::DropdownComponent
  # options are { label:, value:, helptext: } hashes
  def option_text_and_value(option)
    [option[:label], option[:value]]
  end

  # Override to allow adding and styling a helptext for each option
  def before_render
    with_button(classes: "btn btn-outline-secondary dropdown-toggle", label: button_label) unless button

    return if options.any?

    with_options(@choices.map do |option|
      value = option[:value]
      { text: label_text(option), url: helpers.url_for(@search_state.params_for_search(@param => value)), selected: @selected == value }
    end)
  end

  def label_text(option)
    content_tag(:div) do
      safe_join(
        [
          content_tag(:div, option[:label]),
          content_tag(:div, option[:helptext], id: option[:value], class: "dropdown-help-text")
        ]
      )
    end
  end
end
```

#### Creating a New View Partial

One will then integrate the new view component by implementing a new view
template partial `app/views/catalog/_algorithm_select.html.erb`:

```ruby
<% if MyApp.multiple_algorithms_enabled? %>
  <%= render(DropdownHelpTextComponent.new(
    param: :search_algorithm,
    choices: [
      { label: "default", value: "default", helptext: "documents with highest term frequency are first"},
      { label: "alternative search", value: "alternative-search", helptext: "query the documents using an alternative search algorithm." }
    ],
    id: 'search-algorithm-dropdown',
    search_state: search_state,
    default: 'default',
    interpolation: :algorithm,
    selected: search_algorithm_value))
  %>
<% end %>
```

Please substitute within this `MyApp` with the internal name of the Rails
application.

##### i18n Support

One is able to modify the internationalization within the locale file `config/locales/blacklight.en.yml` with the following:

```yaml
en:
  blacklight:
    # [...]
    search:
      search_algorithm:
        label_html: 'Rank by %{algorithm}'
```

##### Styling with CSS or Sass

One may provide styling for the new view component by introducing the following
CSS selectors and properties:

```scss
.dropdown-help-text {
  margin-left: 10px;
  font-size: 0.8em;
  font-style: italic;
}
```

If [Sass](https://sass-lang.com/) is integrated into the Blacklight application, one may introduce this with a new file `app/assets/stylesheets/components/dropdown-help-text.scss`, which is then included within `app/assets/stylesheets/application.scss` using:

```scss
// [...]
@import 'components/dropdown-help-text';
// [...]
```

...which should be placed near the lines of `import` statements.

##### i18n Support

One is able to modify the internationalization within the locale file `config/locales/blacklight.en.yml` with the following:

```yaml
en:
  blacklight:
    # [...]
    search:
      search_algorithm:
        label_html: 'Rank by %{algorithm}'
    # [...]
```

