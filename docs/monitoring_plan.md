# Monitoring Plan

## Health Checks

Monitor `/up` from the load balancer or uptime monitor. Treat failed health
checks, elevated HTTP 5xx rates, and sustained latency increases as deploy
blockers.

## Application Signals

Track:

- request rate, latency, and error rate
- database availability and slow queries
- Solid Queue backlog, failures, retries, and job runtime
- payment webhook failures and replay rejections
- Active Storage read/write failures
- mail delivery failures
- disk usage for any local demo storage

## Logging

Rails logs to STDOUT with request IDs. Production log aggregation should retain
request IDs and payment/order identifiers while avoiding sensitive payloads,
passwords, tokens, webhook secrets, and full payment provider responses.

## Alerts

Alert on:

- `/up` failing
- elevated 5xx rate
- queue backlog growth
- failed payment webhooks
- failed order or booking notifications
- object storage write failures
- database backup failure

## Future Tooling Options

Sentry or Honeybadger can provide exception tracking. Lograge can be introduced
later for denser structured request logs. Managed PostgreSQL and object storage
metrics should become the primary production dashboards after the hosting
provider is selected.
