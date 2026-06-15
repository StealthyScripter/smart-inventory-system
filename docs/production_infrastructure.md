# Production Infrastructure

## Database

Use PostgreSQL for production by setting `DATABASE_URL`. Development and test
remain SQLite so local workflows and CI stay lightweight. The SQLite production
fallback in `config/database.yml` is for demos and single-node smoke tests only.

Before using PostgreSQL in a deployment image, include the PostgreSQL adapter
dependency and verify migrations against a staging database.

## Storage

Use Active Storage with durable object storage. The `amazon_env` service is an
ENV-driven S3-compatible placeholder:

- `ACTIVE_STORAGE_SERVICE=amazon_env`
- `ACTIVE_STORAGE_BUCKET`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

Local disk storage is acceptable for development, test, and controlled demos
with a persistent volume.

## Jobs And Cache

Production uses Solid Queue and Solid Cache. Run queue workers separately from
web processes for real traffic. Persist queue and cache databases when running
the SQLite fallback; when PostgreSQL is active, ensure the cache and queue
databases are migrated and monitored.

## Security Baseline

Production has SSL forcing enabled, secure cookies through Rails `force_ssl`,
request-id tagged logging, a restrictive Content Security Policy, and
environment-only secret handling. Payment and storage secrets must be provided
by the deployment environment.

## Health Endpoint

`GET /up` is the canonical load-balancer and uptime-monitor endpoint. It should
return success without requiring authentication and should not be used as an
application feature route.
