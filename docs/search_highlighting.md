# Highlight fragments of documents that match the user's search query

As part of the Search and Race project we decided to highlight fragments of documents in the search results as an attempt to be transparent with the catalog users. More specifically we emphasize to the users what they searched for and what the catalog returns in the search results.

## Solr Highlighting

Solr provides a HighlightComponent which is in the default list of components for search handlers. There are three highlighters that can be chosen at runtime using the hl parameter in the `solrconfig.xml` file. 
1. [Unified Highlighter](https://solr.apache.org/guide/8_4/highlighting.html#the-unified-highlighter)
2. [Original Highlighter](https://solr.apache.org/guide/8_4/highlighting.html#the-original-highlighter)
3. [FastVector Highlighter](https://solr.apache.org/guide/8_4/highlighting.html#the-fastvector-highlighter)

We decided to use the [Unified Highlighter](https://solr.apache.org/guide/8_4/highlighting.html#the-unified-highlighter). It is the newest highlighter, stands out as the most performant and is recommended in the Solr documentation.

## Configuring Solr to use the Unified highlighter

In the [PUL solr configuration file set the following parameters](https://github.com/pulibrary/pul_solr/blob/main/solr_configs/catalog-production-v2/conf/solrconfig.xml#L132-L136). When the HighlightComponent is active `<str name="hl">true</str>`, Solr creates a `highlighting` section in the solr response. In this `highlighting` section are included the fields that are listed in the `<str name="hl.fl">listed_fields</str>` parameter. The highlighted fields must also be stored in the `schema.xml` file. 
For more information on the highlighting parameters see [Usage - Common Highlighter Parameters](https://solr.apache.org/guide/8_4/highlighting.html#usage)

## Configuring Orangelight to display highlighted Solr fields

* In [Blacklight](https://github.com/pulibrary/orangelight), in order to activate the highlighting feature, the [highlight property must be set to true in the catalog controller](https://github.com/projectblacklight/blacklight/wiki/Blacklight-configuration#solr-hit-highlighting).
* In [Orangelight](https://github.com/pulibrary/orangelight) due to the experimental scope of this project, we put the highlighting feature behind [FlipFlop](https://github.com/voormedia/flipflop) so that we can keep it off until it's ready for production.
* As a first step we decided to highlight matching search terms in the search results and specifically in the title, subject and notes fields.

Related pull requests for this work: 
* [Choose Solr highlighting option](https://github.com/pulibrary/orangelight/issues/3795)
* [Add highlighting feature behind FlipFlop](https://github.com/pulibrary/orangelight/pull/3814)
* [Highlighting screenreader announcement](https://github.com/pulibrary/orangelight/pull/3832/files)
* [Enable highlighting in search results behind FliFlop for title_display,author_display,title_vern_display ](https://github.com/pulibrary/orangelight/pull/3817)
* [Display highlighted Subject or Notes fields](https://github.com/pulibrary/orangelight/pull/3841)
* [Add background color in highlighting](https://github.com/pulibrary/orangelight/pull/3833)
* [Add the HighlightComponent](https://github.com/pulibrary/pul_solr/pull/374)
* [Add author_display field in the schema.xml file explicitly for highlighting](https://github.com/pulibrary/pul_solr/pull/379)
* [Add subject fields in the solr highlighting section ](https://github.com/pulibrary/pul_solr/pull/381)
* [Add notes_display in the solr highlighting section](https://github.com/pulibrary/pul_solr/pull/382/files)
* [Update highlight parameters to emphasize all the matching query terms - not the whole phrase](https://github.com/pulibrary/pul_solr/pull/384)




