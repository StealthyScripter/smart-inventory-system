# Monitoring Plan

## Health Checks

Monitor application boot, HTTP 5xx rates, response latency, database availability, queue availability, and disk space for SQLite and Active Storage.

## Application Errors

Track exceptions from controllers, jobs, mailers, and service objects. Sentry or Honeybadger are good future options.

## Background Jobs

Monitor Solid Queue backlog, failed jobs, retry volume, and job runtime. Alert when mailer or notification queues stop draining.

## Mail Delivery

Track delivery failures, bounces, and provider authentication errors. Mailer failures should not change order, payment, or booking state.

## Storage Failures

Monitor Active Storage write/read failures and disk capacity. Local production storage must be persistent and backed up.

## Future Tooling Options

- Sentry or Honeybadger for exceptions.
- Lograge for structured Rails logs.
- UptimeRobot, Pingdom, or managed load balancer health checks for uptime.
- Managed database/storage metrics after PostgreSQL or object storage migration.
