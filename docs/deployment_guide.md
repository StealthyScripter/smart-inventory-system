# Deployment Guide

## Runtime

Smart Inventory is a Rails 8.1 server-rendered application using SQLite, Solid Queue, Solid Cache, Solid Cable, Active Storage, Hotwire, RSpec, RuboCop, and Brakeman.

## Required Environment Variables

- `RAILS_MASTER_KEY`: required if encrypted credentials are used in production.
- `SECRET_KEY_BASE`: required for Rails sessions and signed data.
- `RAILS_ENV=production`: production runtime mode.
- `DEMO_SEED_CREDENTIAL`: optional credential used only by demo seeds.
- `MANUAL_PAYMENT_WEBHOOK_SECRET`: required if manual/test payment webhook handling is enabled.

Do not hardcode payment, mail, storage, or webhook secrets.

## Database Notes

The current production configuration uses SQLite database files in `storage/`. This is acceptable for a controlled milestone demo but should move to PostgreSQL before marketplace scale or multi-node deployment.

Before deployment:

```sh
bin/rails db:migrate
bin/rails db:seed # only when intentional
```

## Active Storage Notes

Production currently uses local disk storage. Ensure the `storage/` directory is persisted and backed up. Move to S3, GCS, Azure Storage, or another durable object store before high-volume production use.

## Background Jobs

Production uses Solid Queue. Ensure the queue database is persisted and a worker process is running. The app can run Solid Queue in Puma with `SOLID_QUEUE_IN_PUMA`, but a separate worker is preferred for production operations.

## Production Checklist

- Set `RAILS_MASTER_KEY` and `SECRET_KEY_BASE`.
- Confirm mail delivery settings.
- Persist SQLite and Active Storage files.
- Run migrations.
- Run smoke tests after deployment.
- Confirm SSL termination and secure cookies.
- Confirm backup jobs.
- Confirm monitoring and error reporting.
