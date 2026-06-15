# Backup Strategy

## Database Backups

Production marketplace deployments should run PostgreSQL and use both managed
snapshots and logical backups. Keep at least one restore-tested logical backup
path so data can be recovered outside the hosting provider.

Recommended schedule:

- Staging: daily snapshots before QA windows and release candidates.
- Production: hourly snapshots for active marketplaces.
- Production: daily logical backups.
- Production: weekly and monthly retained archives.

SQLite production files under `storage/` are supported only for local/demo
fallbacks. If used, back up the primary, cache, queue, and cable database files
together with the Active Storage files.

## Uploaded Files and Media

Back up object storage buckets with versioning or lifecycle-managed snapshots.
Database and media backups must be restorable to the same point in time because
Active Storage metadata lives in the database while blobs live in object
storage.

## Restore Testing

Test restore before each major release and after changing database or storage
configuration. Verify:

- user login
- catalog browsing
- media display
- cart and checkout
- orders and bookings
- merchant inventory and listings
- admin moderation

## Access Control

Backup credentials must be separate from application runtime credentials where
the hosting platform allows it. Store backup secrets in the deployment secret
manager, not in the repository.
