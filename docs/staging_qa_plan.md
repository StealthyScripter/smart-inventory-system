# Staging QA Plan

## Scope

Validate the v1.2 marketplace maturity release in a staging environment using
seeded demo data. Focus on listing privacy, account boundaries, payment
readiness, and core buyer/merchant/admin workflows.

## Setup

1. Deploy the candidate branch or tag.
2. Set staging-only secrets, including `SECRET_KEY_BASE`,
   `MANUAL_PAYMENT_WEBHOOK_SECRET`, and `DEMO_SEED_CREDENTIAL`.
3. Run `bin/rails db:migrate`.
4. Run `bin/rails db:seed`.
5. Confirm `/up`, `/catalog`, `/services`, `/customers/sign_in`,
   `/merchants/sign_in`, and `/admin/moderation` respond as expected.

## Test Personas

Use `docs/demo_user_matrix.md` for seeded accounts and credentials. Cover one
guest, one customer, one individual merchant, one enterprise owner, one
enterprise employee, and one admin in every full regression pass.

Merchant authentication is available at `/merchants/sign_in` and merchant
registration at `/merchants/sign_up`. Customer authentication is available at
`/customers/sign_in`.

## Pass Criteria

- Guest catalog and service browsing expose only public listings.
- Customers can buy, book, message, track, and review without seeing merchant
  tools.
- Individual merchants can manage their shop, listings, inventory, orders,
  services, bookings, messages, and analytics without team-management tools.
- Enterprise owners/admins can manage members and settings.
- Enterprise employees are limited by role permissions.
- Admin moderation can hide listings/reviews and suspend merchants.
- Manual/test payments work and provider webhooks reject invalid signatures.

## Evidence

Record browser, account, route, expected result, actual result, and any ticket
links for every failed step. A release candidate cannot pass staging QA with
unresolved authorization, payment-state, or public-data-leak issues.
