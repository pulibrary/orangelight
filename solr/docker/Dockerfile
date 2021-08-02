FROM pulibrary/ci-solr:8.4

COPY --chown=$SOLR_USER:$SOLR_USER CJKFoldingFilter.jar /opt/solr/contrib/analysis-extras/lib/.
COPY --chown=$SOLR_USER:$SOLR_USER lucene-umich-solr-filters-6.0.0-SNAPSHOT.jar /opt/solr/contrib/analysis-extras/lib/.
