# syntax=docker/dockerfile:1

FROM solr:7-alpine

COPY --chown=solr:solr ["dist/lire.jar", "dist/liresolr.jar", "/opt/solr/server/solr-webapp/webapp/WEB-INF/lib/"]

RUN rm -rf /opt/solr/server/solr/configsets/_default/conf/

COPY --chown=solr:solr ["conf/", "/opt/solr/server/solr/configsets/_default/conf/"]

CMD ["solr-foreground"]