# Deployment Guide

## Runtime

Smart Inventory is a Rails 8.1 server-rendered application using Hotwire,
importmap, Active Storage, Solid Queue, Solid Cache, RSpec, RuboCop, and
Brakeman.

## Required Environment Variables

- `RAILS_ENV=production`
- `SECRET_KEY_BASE`
- `RAILS_MASTER_KEY` when encrypted credentials are used
- `DATABASE_URL` for production PostgreSQL deployments
- `ACTIVE_STORAGE_SERVICE` for production object storage, for example `amazon_env`
- `ACTIVE_STORAGE_BUCKET`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and
  `AWS_REGION` when using the `amazon_env` storage service
- `MANUAL_PAYMENT_WEBHOOK_SECRET` when manual/test webhooks are enabled
- `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` when Stripe is enabled
- `DEMO_SEED_CREDENTIAL` only for intentional staging/demo seed runs

Do not hardcode payment, mail, storage, or webhook secrets.

## Database

Development and test continue to use SQLite. Production marketplace deployments
should use PostgreSQL through `DATABASE_URL`. The SQLite production entries in
`config/database.yml` remain only as a backwards-compatible fallback for local
containers, demos, and single-node smoke tests.

Before deployment:

```sh
bin/rails db:migrate
bin/rails db:seed # staging/demo only, when intentional
```

Run `bin/rails db:migrate:status` after deploy and before routing production
traffic.

## Active Storage

Local development and tests use disk storage. Production should use durable
object storage by setting `ACTIVE_STORAGE_SERVICE=amazon_env` and the matching
AWS/S3-compatible environment variables. Local production storage is acceptable
only for controlled demos where the `storage/` volume is persistent and backed
up.

## Background Jobs

Production uses Solid Queue. Run a dedicated worker process for production
traffic. `SOLID_QUEUE_IN_PUMA` is acceptable for small staging/demo deploys but
should not be the default for real marketplace load.

## Deployment Steps

1. Build the release image from the tagged commit.
2. Set production environment variables in the hosting platform.
3. Run migrations.
4. Start web and worker processes.
5. Verify `/up`, `/catalog`, merchant login, customer login, checkout, and admin
   moderation smoke tests.
6. Confirm logs, queue processing, backups, and object storage writes.

## Production Checklist

- PostgreSQL is configured through `DATABASE_URL`.
- Active Storage uses durable object storage or a documented persistent volume.
- SSL termination is configured; Rails `force_ssl` is enabled.
- Solid Queue workers are running.
- Mail delivery is configured.
- Backup and restore jobs are scheduled.
- Monitoring and error reporting are active.
- Brakeman has no active warnings.
