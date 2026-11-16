# Dependency-Track API server for Railway.
# Upstream image pinned by version and digest. Bump both together (see CHANGELOG.md).
FROM ghcr.io/dependencytrack/apiserver:5.2.1@sha256:a7ce7a42928c6c03e94e8255e2ee871f5268f55b638a69729cae7afc47ef43b8

USER root
# socat opens the public port only after the default admin password has been replaced.
RUN apk add --no-cache socat
COPY --chmod=755 start.sh /usr/local/bin/railway-start.sh
USER 1000:0

ENV DT_DATA_DIRECTORY=/data
EXPOSE 8080 9000
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/railway-start.sh"]
