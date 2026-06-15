# Account Model QA Report

## Regression status

PASS

## Phase 1: Public experience

- Scenario tested: guest root/catalog/search/services/storefront public access and hidden inventory/listing visibility.
- Expected behavior: `/` renders catalog behavior; guests can browse public marketplace records and cannot see inventory, merchant dashboard, or admin tools.
- Actual behavior: root renders public catalog; public catalog/search/services/storefront routes are accessible; draft/private/archived/local-only/hidden listing records are excluded.
- Bugs found: product moderation archived products but did not hide the associated `MarketplaceListing`; product public scope did not require `marketplace_status = public`.
- Fixes applied: `Product.publicly_listed` now requires public product status and visible listing; admin product hide/approve updates listing status.
- Tests added: expanded admin moderation visibility assertions.

## Phase 2: Customer flow

- Scenario tested: customer onboarding/login, buyer navigation, cart, checkout, order history, booking, review, and forbidden merchant/admin/inventory access.
- Expected behavior: customers land on catalog and only see buyer tools.
- Actual behavior: customer sign-in/sign-up redirects to catalog; cart/checkout/orders/bookings/reviews remain scoped to the customer; merchant/admin/inventory routes are forbidden.
- Bugs found: none in customer routing/access during this loop.
- Fixes applied: none.
- Tests added: no new customer-flow tests in this loop; existing onboarding, cart, order, booking, review, authorization, and navigation specs cover the flow.

## Phase 3: Individual merchant flow

- Scenario tested: individual merchant signup, merchant dashboard landing, shop/listing/inventory/service/order/booking/analytics access, and team management denial.
- Expected behavior: one active owner membership; no enterprise team management.
- Actual behavior: individual merchant accounts create one owner, can access merchant tools, and cannot access team routes.
- Bugs found: none.
- Fixes applied: none.
- Tests added: no new tests in this loop; existing account onboarding, account model, enterprise management, and merchant operating system specs cover the flow.

## Phase 4: Enterprise merchant flow

- Scenario tested: enterprise signup, owner/admin permissions, member add/disable/promote/demote/settings, and default employee role.
- Expected behavior: creator is owner/admin-capable; new members default to employee; non-admins cannot manage members.
- Actual behavior: enterprise owner/admin can manage settings and members; added users default to employee; disabled users lose merchant access.
- Bugs found: none in controller flow during this loop.
- Fixes applied: none.
- Tests added: no new enterprise-flow tests in this loop; existing enterprise account management specs cover the flow.

## Phase 5: Permission matrix

- Scenario tested: catalog manager, inventory manager, order manager, service manager, employee, viewer, owner/admin permissions.
- Expected behavior: each account role can only access permitted tools.
- Actual behavior: role permission helpers and merchant controller filters enforce the matrix; suspended accounts are denied.
- Bugs found: none in permission filters during this loop.
- Fixes applied: none.
- Tests added: no new permission-matrix tests in this loop; existing permission and merchant access control specs cover these roles.

## Phase 6: Inventory privacy

- Scenario tested: local-only inventory, draft/private/archived records, and visible marketplace listings.
- Expected behavior: local/private inventory never appears publicly; marketplace listings appear publicly when visible.
- Actual behavior: catalog discovery uses visible product listings and excludes local-only, draft/private, archived, and hidden products.
- Bugs found: archived product status was not enough to exclude a product if listing remained visible.
- Fixes applied: product public scope now requires both `marketplace_status = public` and visible listing.
- Tests added: admin moderation regression validates hidden products are removed from `Product.publicly_listed`.

## Phase 7: Marketplace listing separation

- Scenario tested: product without listing, visible listing, hidden listing, and inventory preservation after hiding listing.
- Expected behavior: products can exist without listings; hiding a listing does not delete inventory.
- Actual behavior: local/private products can exist without listings; public marketplace products create listings; hidden listings do not delete products.
- Bugs found: admin hide did not hide listing.
- Fixes applied: admin hide sets listing status to `hidden`; approve reactivates public listing.
- Tests added: admin moderation assertion for listing status.

## Phase 8: Legacy compatibility

- Scenario tested: `Supplier`, `SupplierUser`, existing supplier-scoped products/services/orders/bookings, account ownership coexistence, and backfill.
- Expected behavior: old supplier users and records keep working; account mappings can coexist.
- Actual behavior: supplier users still reach merchant dashboard and account-backed users resolve mapped supplier data.
- Bugs found: `AccountBackfill` skipped new `SupplierUser` membership conversion when a supplier already had a merchant account.
- Fixes applied: `AccountBackfill` now always ensures memberships for supplier users, whether account mapping already exists or not.
- Tests added: backfill regression for adding memberships to an existing mapped merchant account.

## Phase 9: Orders

- Scenario tested: customer checkout, merchant order processing/tracking, notifications, order history, analytics.
- Expected behavior: customer orders are customer-scoped; merchants process only own order items.
- Actual behavior: checkout creates customer/account-scoped orders and merchant/account-scoped order items; merchant processing and notifications pass existing lifecycle specs.
- Bugs found: none.
- Fixes applied: none.
- Tests added: no new order tests in this loop; existing order management and tracking specs cover this.

## Phase 10: Service bookings

- Scenario tested: customer service booking, merchant booking updates, notifications, booking history, messaging compatibility.
- Expected behavior: customers and merchants only see their own bookings; status transitions are enforced.
- Actual behavior: booking request/update/history flows remain scoped and pass.
- Bugs found: service review validation did not require a completed service booking.
- Fixes applied: service reviews now require a completed booking for the customer/service/supplier.
- Tests added: review model tests for completed service booking requirement.

## Phase 11: Messaging

- Scenario tested: customer-to-merchant conversations, participant scoping, unread handling, and notifications.
- Expected behavior: only conversation participants can access; messages notify recipients.
- Actual behavior: existing messaging specs pass, including unauthorized access denial and unread read-marking.
- Bugs found: none.
- Fixes applied: none.
- Tests added: none in this loop.

## Phase 12: Reviews

- Scenario tested: product reviews, service reviews, duplicate prevention, unauthorized reviews, ratings.
- Expected behavior: only completed purchases/bookings allow reviews; duplicates are prevented.
- Actual behavior: product review rules already enforced delivered purchase; service review rules now enforce completed booking.
- Bugs found: service reviews could be created without a completed booking and could be duplicated.
- Fixes applied: added completed service booking validation and uniqueness on `service_listing_id` scoped to user.
- Tests added: review model tests for service booking requirement and duplicate service reviews.

## Phase 13: Enterprise team management

- Scenario tested: last owner/admin protection, disabled users, immediate role changes.
- Expected behavior: last owner/admin cannot be removed; disabled users lose access; role changes affect permissions.
- Actual behavior: existing enterprise management specs pass.
- Bugs found: none.
- Fixes applied: none.
- Tests added: none in this loop.

## Phase 14: Admin

- Scenario tested: admin moderation, reports, merchant suspension, non-admin denial.
- Expected behavior: admins can moderate listings/reviews/suppliers/reports; non-admins cannot.
- Actual behavior: admin moderation works and non-admin routes are forbidden.
- Bugs found: supplier suspension paused the supplier but did not suspend the mapped merchant account.
- Fixes applied: supplier suspend/approve moderation now updates mapped merchant account status.
- Tests added: admin moderation assertion for account suspension.

## Phase 15: Security regression

- Scenario tested: privilege escalation, IDOR, cross-account/customer/merchant access, Brakeman.
- Expected behavior: no active Brakeman warnings; scoped routes prevent cross-account access.
- Actual behavior: Brakeman reported no active warnings in the prior security run; final run is recorded below.
- Bugs found: review authorization and moderation/account-suspension gaps described above.
- Fixes applied: small validation and moderation fixes.
- Tests added: focused model/request regressions.

## Phase 16: Seed data

- Scenario tested: `bin/rails db:seed`.
- Expected behavior: seed creates customers, merchants, enterprise employees, products, listings, services, orders, bookings, reviews, analytics data.
- Actual behavior: seed completed successfully before this report; final seed result is recorded below.
- Bugs found: none in this loop.
- Fixes applied: none.
- Tests added: no new seed specs in this loop; existing demo seed and account backfill specs pass.

## Phase 17: Final regression

- Scenario tested: full RSpec, RuboCop, Zeitwerk, Brakeman.
- Expected behavior: all green.
- Actual behavior: final results are recorded below.
- Bugs found: none after fixes.
- Fixes applied: none after final gate.
- Tests added: included in the loop above.

## Verification results

- RSpec: 292 examples, 0 failures.
- RuboCop: 233 files inspected, no offenses.
- Zeitwerk: all good.
- Brakeman: 0 security warnings, 1 ignored warning from existing ignore file.
- Seed: completed successfully; demo data includes 9 products, 5 services, 2 orders, 1 booking, and account backfill-created account data.

## Bugs fixed

- Service reviews now require completed service bookings.
- Duplicate service reviews are blocked per user/service.
- Product moderation hide now hides the associated marketplace listing.
- `Product.publicly_listed` now requires public product status and visible listing.
- Supplier moderation suspend/approve now updates mapped merchant account status.
- Account backfill now adds memberships for new legacy supplier users even when the supplier already has an account mapping.
- Account backfill now promotes existing individual merchant mappings to enterprise merchant accounts when legacy supplier data has multiple supplier users.

## Remaining risks

- Legacy `SupplierUser` fallback remains intentionally broad for compatibility until production backfill is verified.
- Service listings are still public through `ServiceListing` directly; product listing separation is stronger than service listing separation.
- Account ownership columns remain nullable for backward compatibility.

## Recommendation

READY TO MERGE INTO MAIN
