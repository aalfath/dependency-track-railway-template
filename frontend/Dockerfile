# Dependency-Track frontend for Railway.
# Upstream image pinned by version and digest. Keep it on the same version as apiserver/.
FROM ghcr.io/dependencytrack/frontend:5.2.1@sha256:1c0f63b083af8e89ff4ede5e7ed5cfc4e23ab871fa140ed101e8dc56f53eb51c

# Same-origin setup: nginx serves the app and proxies /api/ to the private API server.
COPY --chown=101:0 default.conf.template /etc/nginx/templates/default.conf.template
COPY --chmod=755 05-railway.envsh /docker-entrypoint.d/05-railway.envsh

ENV API_BASE_URL="" \
    NGINX_ENVSUBST_FILTER="^(BASE_PATH|NGINX_RESOLVER|API_UPSTREAM|PORT)$"
EXPOSE 8080
