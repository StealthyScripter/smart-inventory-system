# Disaster Recovery

## Failure Scenarios

- Application deploy failure.
- Database file corruption or accidental deletion.
- Active Storage media loss.
- Background job queue failure.
- Mail delivery outage.
- Compromised credentials.

## Restore Steps

1. Stop write traffic if data integrity is uncertain.
2. Identify the last known good code tag and backup set.
3. Restore database files and Active Storage files from matching backups.
4. Boot the application in maintenance or staging mode.
5. Run migrations only when required by the restored code version.
6. Verify login, catalog, merchant dashboards, orders, bookings, media, and admin pages.
7. Reopen traffic and monitor errors.

## Incident Response Checklist

- Record incident start time and affected systems.
- Assign incident owner.
- Preserve logs and failed artifacts.
- Rotate exposed secrets.
- Communicate customer or merchant impact.
- Document root cause and prevention actions.
