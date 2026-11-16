# Changelog

## 5.2.1 (2026-11-16)

- First release of the template: Dependency-Track 5.2.1 (API server and frontend, pinned by digest) with Railway PostgreSQL.
- The frontend is the only public service and proxies `/api/` to the private API server.
- The API server replaces the default `admin`/`admin` password with the generated `ADMIN_PASSWORD` before its port opens.
