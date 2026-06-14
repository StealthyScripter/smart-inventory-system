# Production Readiness Checklist

## Code Quality

- RSpec passes.
- RuboCop passes.
- Zeitwerk check passes.
- Brakeman has no active warnings.
- CI runs tests, lint, autoload, and security scans.

## Database

- Migrations are up.
- Backups are configured.
- Restore has been tested.
- PostgreSQL migration is planned before marketplace scale.

## Environment

- `SECRET_KEY_BASE` is set.
- `RAILS_MASTER_KEY` is set when credentials are used.
- `MANUAL_PAYMENT_WEBHOOK_SECRET` is set if payment webhooks are enabled.
- No secrets are committed.

## Operations

- SSL is configured.
- Mailer settings are configured.
- Solid Queue worker is running.
- Active Storage is persistent and backed up.
- Monitoring and error reporting are active.
- Demo seeds are not run against production unless intentional.

## Marketplace Safety

- Public catalog exposes only public marketplace records.
- Merchant data is supplier-scoped.
- Customer data is customer-scoped.
- Admin governance is admin-only.
- Local/private inventory is protected from public views.
