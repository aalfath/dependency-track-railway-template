#!/bin/sh
# Start the Dependency-Track API server on Railway.
#
# Upstream seeds a managed user admin/admin on first start. This script keeps the
# REST API on loopback until that default password has been replaced with
# ADMIN_PASSWORD, and only then forwards the service port (PORT, default 8080) to it.
# So the default password is never reachable over the network.
set -eu

DATA_DIR="${DT_DATA_DIRECTORY:-/data}"
if [ "$(id -u)" = 0 ]; then
  # Railway mounts volumes owned by root: hand the data directory to the upstream user, then drop root.
  mkdir -p "$DATA_DIR"
  find "$DATA_DIR" ! -user 1000 -exec chown 1000:0 {} + 2>/dev/null || true
  exec su-exec 1000:0 "$0" "$@"
fi

PORT="${PORT:-8080}"
INTERNAL_PORT="${DT_INTERNAL_PORT:-8081}"
ADMIN_USER=admin

log() { echo "[railway-start] $*"; }

ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
if [ "${#ADMIN_PASSWORD}" -lt 12 ]; then
  log "ADMIN_PASSWORD must be set and at least 12 characters long. Refusing to start."
  exit 1
fi

# Build the JDBC URL from Railway's Postgres variables unless DT_DATASOURCE_URL is given.
if [ -z "${DT_DATASOURCE_URL:-}" ]; then
  if [ -z "${PGHOST:-}" ]; then
    log "Set DT_DATASOURCE_URL or PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD."
    exit 1
  fi
  export DT_DATASOURCE_URL="jdbc:postgresql://${PGHOST}:${PGPORT:-5432}/${PGDATABASE:-railway}"
  export DT_DATASOURCE_USERNAME="${DT_DATASOURCE_USERNAME:-${PGUSER:-postgres}}"
  export DT_DATASOURCE_PASSWORD="${DT_DATASOURCE_PASSWORD:-${PGPASSWORD:-}}"
fi


# The JVM sizes its heap from the host's memory on Railway: cap it (JAVA_HEAP, default 2g).
EXTRA_JAVA_OPTIONS="${EXTRA_JAVA_OPTIONS:-} -Xmx${JAVA_HEAP:-2g}"

log "Starting API server on 127.0.0.1:${INTERNAL_PORT}"
# shellcheck disable=SC2086
java ${JAVA_OPTIONS} ${EXTRA_JAVA_OPTIONS:-} \
  --add-opens java.base/java.util.concurrent=ALL-UNNAMED \
  --enable-native-access=ALL-UNNAMED \
  --sun-misc-unsafe-memory-access=allow \
  -Djdk.http.auth.tunneling.disabledSchemes= \
  -cp 'dependency-track-apiserver.jar:lib/*:lib-external/*' \
  org.dependencytrack.Application \
  -context "${CONTEXT:-/}" -host 127.0.0.1 -port "${INTERNAL_PORT}" &
JAVA_PID=$!

stop() { kill -TERM "$JAVA_PID" 2>/dev/null || true; [ -n "${SOCAT_PID:-}" ] && kill -TERM "$SOCAT_PID" 2>/dev/null; wait "$JAVA_PID" 2>/dev/null; exit 0; }
trap stop TERM INT

# Wait until the REST API answers (first start runs the database migrations).
i=0
until wget -q -Y off -T 3 -O /dev/null "http://127.0.0.1:${INTERNAL_PORT}/api/version" 2>/dev/null; do
  kill -0 "$JAVA_PID" 2>/dev/null || { log "API server exited during startup."; wait "$JAVA_PID"; exit 1; }
  i=$((i + 1))
  [ $((i % 15)) -eq 0 ] && log "Waiting for the API server ($((i * 2)) s)"
  sleep 2
done
log "API server is up."

# Replace the seeded default password. 200 = replaced now; 401 = it was already changed.
code=$(wget -q -Y off -T 20 -S -O /dev/null \
  --post-data "username=${ADMIN_USER}&password=admin&newPassword=$(printf %s "$ADMIN_PASSWORD" | sed 's/%/%25/g;s/&/%26/g;s/+/%2B/g;s/=/%3D/g;s/ /%20/g')&confirmPassword=$(printf %s "$ADMIN_PASSWORD" | sed 's/%/%25/g;s/&/%26/g;s/+/%2B/g;s/=/%3D/g;s/ /%20/g')" \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  "http://127.0.0.1:${INTERNAL_PORT}/api/v1/user/forceChangePassword" 2>&1 | awk '/^  HTTP\//{c=$2} END{print c}') || true
case "$code" in
  200) log "Default admin password replaced with ADMIN_PASSWORD (user '${ADMIN_USER}')." ;;
  401|403) log "Default admin password already changed; leaving the account as it is." ;;
  *) log "Could not verify the admin password (HTTP '${code}'). Refusing to open the port."; stop ;;
esac

log "Opening port ${PORT}"
if [ -f /proc/net/if_inet6 ]; then LISTEN="TCP6-LISTEN:${PORT},ipv6only=0"; else LISTEN="TCP4-LISTEN:${PORT}"; fi
socat "${LISTEN},fork,reuseaddr" "TCP4:127.0.0.1:${INTERNAL_PORT}" &
SOCAT_PID=$!

# Exit (and let Railway restart us) if either process dies.
while kill -0 "$JAVA_PID" 2>/dev/null && kill -0 "$SOCAT_PID" 2>/dev/null; do sleep 5; done
log "A process exited; stopping."
kill -TERM "$JAVA_PID" "$SOCAT_PID" 2>/dev/null || true
wait "$JAVA_PID" 2>/dev/null || true
exit 1
