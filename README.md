# Dependency-Track on Railway

Railway template for [OWASP Dependency-Track](https://dependencytrack.org/), the SBOM-based platform for tracking component risk (vulnerabilities, licences, policy violations) across your software portfolio.

**Version:** Dependency-Track **5.2.1** (API server and frontend), images pinned by digest:

| Service | Folder | Image |
|---|---|---|
| Dependency-Track (public) | `frontend/` | `ghcr.io/dependencytrack/frontend:5.2.1@sha256:1c0f63b083af8e89ff4ede5e7ed5cfc4e23ab871fa140ed101e8dc56f53eb51c` |
| API Server (private) | `apiserver/` | `ghcr.io/dependencytrack/apiserver:5.2.1@sha256:a7ce7a42928c6c03e94e8255e2ee871f5268f55b638a69729cae7afc47ef43b8` |
| Postgres | Railway PostgreSQL | |

## What it deploys

- **Dependency-Track**: the web UI (nginx). It has the only public domain and proxies `/api/` to the API server over Railway's private network, so the UI and the REST API share one URL (`https://YOUR-DOMAIN/api/...`) and no CORS setup is needed.
- **API Server**: the Java API server with a volume on `/data` (keys, file storage). It talks to Postgres over the private network.
- **Postgres**: Railway's PostgreSQL, which holds all of Dependency-Track's data.

## First login

Upstream creates a user `admin` with the password `admin`. In this template, the API server's start script (`apiserver/start.sh`) keeps the REST API on loopback, replaces that default password with the generated `ADMIN_PASSWORD`, and only then opens its port. So the default password is never reachable.

Log in as `admin` with the `ADMIN_PASSWORD` value from the **API Server** service's Variables tab. Then create your own users or connect OIDC or LDAP.

## Variables

| Service | Variable | Default | Purpose |
|---|---|---|---|
| API Server | `ADMIN_PASSWORD` | generated, 24 letters and digits | Password set for the `admin` user on first start |
| API Server | `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD` | references to Postgres | Database connection |
| API Server | `PORT` | `8080` | Port the API server listens on (private network) |
| API Server | `JAVA_HEAP` | `2g` | JVM maximum heap |
| Dependency-Track | `API_UPSTREAM` | `${{API Server.RAILWAY_PRIVATE_DOMAIN}}:8080` | Where nginx sends `/api/` requests |
| Dependency-Track | `PORT` | `8080` | Port nginx listens on |

Any other upstream setting can be added as a variable: see the [configuration reference](https://dependencytrack.github.io/docs/reference/configuration/properties/) (for example `DT_OIDC_ENABLED`, `DT_LDAP_ENABLED`, `DT_TELEMETRY_SUBMISSION_DEFAULT_ENABLED=false`). Frontend OIDC settings (`OIDC_ISSUER`, `OIDC_CLIENT_ID`) go on the Dependency-Track service.

## Resources

Upstream suggests about 2 GB of memory for the API server and at least 4 GB for PostgreSQL in production. The first vulnerability mirror (NVD, GitHub Advisories, OSV) runs in the background after the first start and can take a while.

## Updates

Each service builds from this repository's `main` branch. When a new Dependency-Track release is pinned here (both Dockerfiles together) and merged to `main`, Railway shows deployers an "update available" notice, and they choose when to apply it. Read `CHANGELOG.md` and the [upstream upgrade notes](https://dependencytrack.github.io/docs/next/guides/upgrading/) before applying an update.
