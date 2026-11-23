# Dependency-Track frontend for Railway.
# Upstream image pinned by version and digest. Keep it on the same version as apiserver/.
FROM ghcr.io/dependencytrack/frontend:5.2.2@sha256:fd15b6cdc38692518a703eab0ed2867fa34e1276034cbe00773c61a9975cf719

# Same-origin setup: nginx serves the app and proxies /api/ to the private API server.
COPY --chown=101:0 default.conf.template /etc/nginx/templates/default.conf.template
COPY --chmod=755 05-railway.envsh /docker-entrypoint.d/05-railway.envsh

ENV API_BASE_URL="" \
    NGINX_ENVSUBST_FILTER="^(BASE_PATH|NGINX_RESOLVER|API_UPSTREAM|PORT)$"
EXPOSE 8080
