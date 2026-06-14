# Freeze Readiness Audit

Date: 2026-06-14

Scope: Smart Inventory Rails application after completion of Phases 1-26.

## Commands Run

Baseline and final verification:

- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec`
- `docker-compose run --rm -e RAILS_ENV=test app bin/rubocop`
- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check`
- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rails db:migrate:status`
- `docker-compose run --rm app bundle exec brakeman`
- `docker-compose run --rm app bin/rails db:migrate`
- `docker-compose run --rm app bin/rails db:seed`

## Results

- RSpec: `226 examples, 0 failures`
- RuboCop: `204 files inspected, no offenses detected`
- Zeitwerk: `All is good!`
- Migration status: all migrations are `up` through `20260614016000_add_real_world_readiness_fields`
- Brakeman: `0` active security warnings, `0` errors, `1` ignored warning from existing ignore file
- Seed check: passed after applying development migrations

## Issues Found

1. CSV import accepted malformed input too implicitly.
2. Media upload associations did not validate file type or size.
3. `Product#total_stock` and `Product#available_stock` always queried the database even when stock levels were already eager-loaded.
4. Customer booking privacy was implemented but lacked direct request coverage for cross-customer cancellation attempts.

## Fixes Applied

- Added strict merchant product CSV import validation:
  - Exact header validation.
  - Required field validation for `sku`, `name`, `category`, and `supplier`.
  - Malformed row and unterminated quoted field rejection.
  - Existing merchant supplier scoping remains enforced during import.
- Added `ImageAttachmentValidatable` concern:
  - Restricts Active Storage attachments to `image/*`.
  - Limits each image attachment to 5MB.
  - Applied to products, services, suppliers, and reviews.
- Optimized product stock summary methods to use already-loaded `stock_levels` where possible.
- Added request coverage proving customers cannot cancel another customer's booking.

## Tests Added

- CSV import rejects invalid headers.
- CSV import rejects malformed rows.
- Product media validation rejects non-image attachments.
- Customer booking cancellation remains scoped to the current customer.

## Security Findings

- Authentication uses session-backed login with password hashing.
- CSRF remains enabled for normal controllers.
- Webhook endpoint uses `ActionController::API` and verifies HMAC signatures for the manual/test payment provider.
- Admin governance and reports are admin-only.
- Merchant controllers require linked supplier users.
- Customer controllers require customer users.
- Brakeman reports no active warnings.

## Privacy Findings

- Customers are scoped to their own orders, bookings, conversations, analytics, notifications, and cart.
- Merchants are scoped through `SupplierUser` to their own products, inventory, bookings, orders, services, shop settings, conversations, and analytics.
- Public catalog/search/service pages use public listing scopes and hide draft/private/archived records.
- Media display follows the same public/private listing boundaries as the parent records.

## Performance Findings

- Catalog, service, search, and marketplace discovery pages use bounded result limits.
- Common marketplace discovery and status fields are indexed.
- Product stock summary methods now avoid extra aggregate queries when stock levels are eager-loaded.
- Remaining larger optimization TODO: live dashboard and analytics totals are still calculated directly from transactional tables; introduce rollups only when usage data proves it necessary.

## Data Integrity Findings

- Core statuses are constrained by model validations for orders, order items, payments, bookings, services, products, reports, moderation actions, and reviews.
- Review rating bounds and duplicate review prevention are enforced.
- SKU and barcode uniqueness are enforced.
- Inventory shipment flow checks stock before deduction.
- Soft-delete/restore actions preserve records while changing public visibility state.

## File and Media Findings

- Active Storage is local/test configured.
- Product, service, merchant, and review attachments are now image-only and size-limited.
- Public pages only render media through records already authorized for public display.

## Background Job and Mailer Findings

- Notification email jobs use the `mailers` queue and retry failures.
- Daily notification digest job uses the `notifications` queue and safely skips users without unread notifications.
- Mailers render operational context without exposing unrelated customer, merchant, or payment data.

## CSV, PDF, Barcode, and QR Findings

- CSV export is merchant-scoped.
- CSV import is merchant-scoped and now validates headers, required fields, and malformed rows.
- PDF receipt and estimate endpoints are scoped through customer and merchant controllers.
- Barcode and QR endpoints use existing product authorization.

## Maintainability Findings

- Phase 22-26 additions remain in Rails conventions: controllers, concerns, PORO services, mailers, jobs, and request/model/service specs.
- No new feature domains, external services, microservices, or payment providers were introduced during the audit.
- Larger TODO: extract repeated inline styles into a stylesheet before UI stabilization, but this is not freeze-blocking.

## Remaining TODOs

- Move from live analytics queries to cached/rolled-up summaries if traffic requires it.
- Replace lightweight PDF generation with a dedicated document renderer if invoice/estimate formatting requirements grow.
- Add account verification, password reset, lockout/rate limiting, and MFA before broad public launch.
- Move production persistence from SQLite to PostgreSQL before marketplace scale.
- Review repository secret handling before production release.
- Keep real payment providers, Jenga integration, push notifications, external search, RFQs, and auctions deferred.

## Freeze Recommendation

READY WITH MINOR TODOs

The application is passing tests, style checks, autoload checks, migration checks, Brakeman, and seed verification. The remaining items are operational hardening or scale-oriented improvements, not blockers for entering stabilization mode.
