# Search Algorithm Switching

As part of the Search and Race project work, we've decided to explore allowing users to
submit their searches using different search algorithms.

## Context

We could do this primarily in ruby code or primarily in Solr.

### Solr Request Handler

Define weights in the solrconfig. Use a sew SearchBuilder to submit searches with "qt=different_algorithm" instead of "qt=search".
* Pros:
    * Maximum functionality
    * hides a bunch of parameters.
* Cons:
    * Have to maintain two request handlers, have to deploy.

### Blacklight Request Parameters

In ruby code, add weights to the search query Blacklight sends. This was done in an [earlier test](https://docs.google.com/document/d/1ROvFH-dy2pWneRmouYZiHvnSBSxGkLt7ygb6CCsx1-Y/edit). Use a new SearchBuilder to submit searches with the required boost params

### Optional indexing strategy

In either case we could index the boost values for the strategy we want to use, resulting in a solr query like select?boost=boost_sort. This would potentially make queries faster, but require reindexing to deploy. This would also improve readability of the boost values. It may also afford greater flexibility in calculating boost values, e.g. pulling from another data set.

## Implementation

We will create a SearchBuilder and request handler for each algorithm we offer
as a search endpoint. Each SearchBuilder will inherit from the Blacklight
SearchBuilder.

### Consequences

* We will have more classes
* We will have greater flexibility in customizing the search behvaior
* We isolate this feature from the rest of the code base, making it easier to pull into other applications.
