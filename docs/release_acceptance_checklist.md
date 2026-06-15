# Release Acceptance Checklist

## Automated Gates

- RSpec passes.
- RuboCop passes.
- Zeitwerk check passes.
- Brakeman reports no active warnings.
- `rails db:migrate:status` is clean.
- `rails db:seed` completes in a fresh environment.

## Marketplace

- Public catalog queries marketplace listings.
- Local-only inventory never appears publicly.
- Draft, private, and archived listings are hidden.
- Listing visibility can change without deleting inventory.
- Service listings honor explicit visibility/status rules.

## Accounts And Access

- Customer, individual merchant, enterprise merchant, and admin flows are
  distinct.
- Enterprise added users default to employee.
- Role changes take effect immediately.
- Disabled users lose merchant access.
- Last owner/admin protection holds.

## Payments

- Manual/test provider works.
- Provider selection is explicit and validated.
- Missing real-provider credentials fail safely.
- Invalid webhooks are rejected.
- Duplicate webhooks are idempotent.
- Paid order state requires a verified successful payment event.

## Production Readiness

- PostgreSQL production plan is documented.
- Durable object storage plan is documented/configured.
- `/up` is monitored.
- Queue workers are running.
- Backups and restore test are scheduled.
- Staging QA scripts have been executed.

## Decision

Release only when every automated gate passes and no open staging issue can
cause data loss, payment-state corruption, cross-account access, or public
leakage of private inventory data.
