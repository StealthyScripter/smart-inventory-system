# Scalability Plan

## Current Baseline

- Rails monolith.
- SQLite.
- Server-rendered pages.
- Solid Queue/Cache/Cable configured.
- No background domain jobs.
- No CDN/object storage usage.

## 10,000 Users

- Keep monolith.
- Add database indexes for common filters.
- Add fragment/low-level caching for catalog and dashboard summaries.
- Use Solid Queue for async emails, reports, webhook processing.
- Add pagination to product, order, and inventory screens.
- Add authorization matrix tests before expanding access.

## 100,000 Users

- Move production database to PostgreSQL.
- Use Redis for cache/session/rate-limiting if Solid Cache is insufficient.
- Put static assets behind a CDN.
- Add object storage for product/media attachments.
- Add background jobs for search indexing, notifications, analytics rollups.
- Add read-optimized reporting tables or materialized views.
- Monitor slow queries and add composite indexes.

## 1 Million Users

- Keep the application as a well-structured monolith until scaling data proves otherwise.
- Split internal domains by namespace and service objects, not repositories.
- Use PostgreSQL read replicas where needed.
- Use dedicated search infrastructure, likely Meilisearch first or Elasticsearch if requirements demand it.
- Move heavy analytics to async rollups.
- Add queue isolation by workload.
- Add CDN-backed media transformations.
- Introduce stricter rate limiting and abuse detection.

## Guardrails

- Do not introduce microservices prematurely.
- Do not split merchant/customer/admin into separate codebases.
- Scale the Rails monolith through database, caching, jobs, search, and clear internal boundaries first.

