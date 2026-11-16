# Dependency-Track API server for Railway.
# Upstream image pinned by version and digest. Bump both together (see CHANGELOG.md).
FROM ghcr.io/dependencytrack/apiserver:5.2.1@sha256:a7ce7a42928c6c03e94e8255e2ee871f5268f55b638a69729cae7afc47ef43b8

USER root
# socat opens the service port only after the default admin password has been replaced.
# su-exec drops to the upstream user (1000) after the start script fixes the volume's owner
# (Railway mounts volumes as root).
RUN apk add --no-cache socat su-exec
COPY --chmod=755 start.sh /usr/local/bin/railway-start.sh

ENV DT_DATA_DIRECTORY=/data
EXPOSE 8080 9000
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/railway-start.sh"]
