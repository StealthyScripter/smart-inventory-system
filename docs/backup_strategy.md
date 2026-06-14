# Backup Strategy

## Database Backups

Back up all production SQLite files under `storage/`, including primary, cache, queue, and cable databases if present. Schedule at least daily backups, with more frequent snapshots for active production usage.

For PostgreSQL future deployments, use managed snapshots plus logical backups with restore testing.

## Uploaded Files and Media

Back up Active Storage files under `storage/`. Database and media backups must be retained as matching restore points because Active Storage metadata lives in the database.

## Frequency

- Demo or staging: daily.
- Production: hourly database snapshots for active marketplaces, daily full backups, and retained weekly/monthly archives.

## Restore Testing

Test restore at least before each major release and after changing storage configuration. Verify login, catalog browsing, media display, orders, bookings, and merchant dashboards after restoration.
