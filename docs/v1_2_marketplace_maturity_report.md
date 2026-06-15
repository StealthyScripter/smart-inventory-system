# v1.2 Marketplace Maturity Report

## Listing Separation Summary

Public catalog product browsing now queries visible `MarketplaceListing` records
instead of raw private `Product` inventory records. Product pages render public
listing title, description, price, sale price, and availability while keeping
SKU, unit cost, internal stock, and private inventory details out of the
customer view.

`Product` remains the inventory object. `MarketplaceListing` owns public
sellable fields including title, public description, public price, sale price,
availability, listing status, visibility, shipping eligibility, search tags,
and featured media URL. Merchant product management separates inventory fields
from listing fields.

`ServiceListing` remains the public service object but now has explicit
visibility/status rules so draft, private, and archived services stay out of
public service browsing.

## Payment Readiness Summary

Payments now use a pluggable provider layer:

- `PaymentProviders::ManualProvider`
- `PaymentProviders::StripeProvider`
- `PaymentProviders::Registry`

Manual/test payments remain the default. Stripe readiness is present without
requiring live credentials or the Stripe gem. Missing Stripe credentials fail
safely without creating a payment. Webhook verification is provider-specific,
invalid signatures are rejected, duplicate webhook event IDs are ignored, and
paid order state requires a verified successful provider event.

## Production Infrastructure Summary

Development and test continue to use SQLite and local/test storage. Production
readiness now documents PostgreSQL through `DATABASE_URL`, durable object
storage through ENV-driven Active Storage configuration, Solid Queue worker
expectations, Solid Cache usage, `/up` health monitoring, backup/restore
requirements, and security baseline settings.

The app keeps backwards-compatible local production fallbacks for controlled
demos, but production marketplace deployments should use PostgreSQL and object
storage.

## Human QA And Staging Summary

New staging QA materials cover guest, customer, individual merchant, enterprise
merchant, admin, payment, and release acceptance flows:

- `docs/staging_qa_plan.md`
- `docs/manual_test_scripts.md`
- `docs/demo_user_matrix.md`
- `docs/release_acceptance_checklist.md`

Demo seed tests now verify seeded customer accounts, individual merchants,
enterprise merchant membership, public products/listings, services, orders,
bookings, reviews, and idempotency.

## Tests Added

- marketplace listing privacy and merchant listing-field separation coverage
- payment provider selection, missing credential safety, Stripe-ready webhook,
  invalid signature, and duplicate webhook tests
- health endpoint and test-safe storage hardening tests
- staging QA route-render tests
- explicit demo seed account-type and enterprise employee assertions
- review and moderation compatibility coverage retained from the account-model
  QA pass

## Final Verification Results

- RSpec: 303 examples, 0 failures
- RuboCop: 239 files inspected, no offenses
- Zeitwerk: all good
- Test migration status: all migrations up, including
  `20260615007000 Add public listing fields`
- Seed: passed after applying the pending development/demo migration
- Brakeman: 0 active security warnings, 1 ignored warning

## Remaining Risks/TODOs

- Add the official Stripe gem and live Checkout Session or Payment Intent
  creation in a dedicated payment hardening cycle.
- Add the PostgreSQL adapter dependency and run full staging migrations against
  a real PostgreSQL database before production marketplace traffic.
- Configure the selected object storage provider and verify uploads, downloads,
  backups, and restores in staging.
- Execute the manual staging QA plan with humans before merging into a release
  branch.

## Recommendation

READY TO MERGE INTO MAIN after human staging QA completes.
