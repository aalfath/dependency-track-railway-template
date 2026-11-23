# Changelog

## 5.2.2 (2026-11-23)

- Breaking changes: none. No new variables.
- Security release: pins FreeMarker 2.3.35 (CVE-2026-84939), snappy-java and the Java runtime (CVE-2026-114938). See the [5.2.2 release notes](https://github.com/DependencyTrack/dependency-track/releases/tag/5.2.2).
- Dependency-Track 5.2.1 → **5.2.2**: API server `ghcr.io/dependencytrack/apiserver:5.2.2@sha256:cd5bed12ff30fd36980dbee2d6c3b177c37b99c63b60f5a5b15fbca0b31d0f38`, frontend `ghcr.io/dependencytrack/frontend:5.2.2@sha256:fd15b6cdc38692518a703eab0ed2867fa34e1276034cbe00773c61a9975cf719`.
- Tested on Railway before merging: the published template was deployed, data was written, the service was switched to this version, and the data and login were still there.

## 5.2.1-1 (2026-11-16)

- README: added the Deploy on Railway button for the published template (`dependency-track-1`). No change to the services.

## 5.2.1 (2026-11-16)

- First release of the template: Dependency-Track 5.2.1 (API server and frontend, pinned by digest) with Railway PostgreSQL.
- The frontend is the only public service and proxies `/api/` to the private API server.
- The API server replaces the default `admin`/`admin` password with the generated `ADMIN_PASSWORD` before its port opens.
