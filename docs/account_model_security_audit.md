# Account Model Security Audit

## Scope

This audit covers the account-model refactor through the customer, individual merchant, enterprise merchant, legacy supplier, marketplace listing, onboarding, and account backfill layers.

## Access boundaries

- Guests can access catalog, search, public merchant storefronts, public service pages, customer and merchant sign-in/sign-up pages, and health checks.
- Customers can access catalog, cart, checkout, customer orders, customer bookings, customer conversations, reviews, reports, and notifications.
- Customer-only users are blocked from merchant management routes.
- Individual merchant accounts are limited to one active membership and do not expose team management routes.
- Enterprise merchant memberships control merchant management access by account role.
- Suspended merchant accounts are blocked from merchant management routes through account membership permission checks.
- Legacy `SupplierUser` access remains as a transitional compatibility path and is intentionally permissive only when no account-backed merchant context is active for the user.
- Admin routes still require platform-level admin access.

## Permission model

Merchant permissions are defined on `AccountMembership`:

- `owner` and `admin`: all account permissions.
- `manager`: operational permissions except member/role administration.
- `catalog_manager`: catalog and listing management.
- `inventory_manager`: inventory viewing, stock adjustment, and location management.
- `order_manager`: order viewing, management, and fulfillment.
- `service_manager`: service and booking management.
- `support_staff`: order viewing and booking management.
- `employee` and `viewer`: read-oriented inventory/order access.

Enterprise member management requires `manage_members`. Account settings require `manage_account_settings`.

## Customer data

Customer ownership remains user-compatible and is now optionally account-backed:

- `Cart#customer_account_id`
- `Order#customer_account_id`
- customer profile through `CustomerProfile`

Customer account data is not exposed through merchant routes except via existing transactional surfaces such as orders, bookings, and conversations.

## Merchant data

Merchant ownership remains supplier-compatible and is now optionally account-backed:

- `Product#account_id`
- `ServiceListing#account_id`
- `OrderItem#account_id`
- `ServiceBooking#account_id`
- `Conversation#account_id`
- `Review#account_id`
- `StockLevel#account_id`
- `StockMovement#account_id`

Merchant controllers scope through account ownership and legacy supplier ownership. Existing supplier references are preserved for procurement and compatibility.

## Marketplace visibility

Public product discovery now depends on visible `MarketplaceListing` records for product listings. Local-only products and hidden/private listings do not appear in the public catalog.

## Messaging

Conversation access allows the customer, legacy supplier users, and active members of the mapped merchant account. This preserves existing messaging while enabling enterprise members to share support access.

## CSV import/export and analytics

Merchant CSV and analytics flows continue to scope through `merchant_suppliers`, now resolved from account-backed merchant profiles and legacy supplier users. Further Phase 12 or post-freeze hardening should add dedicated permission tests for CSV import/export and analytics access by role.

## Media

Media attachments remain governed by existing model validations. The account refactor did not introduce direct public media management routes.

## Brakeman

Brakeman should be run after this audit. Any active high or critical findings must be triaged before freeze.

## Residual risks

- Legacy `SupplierUser` fallback is intentionally broad for compatibility; it should be tightened after data migration proves complete.
- Supplier remains dual-purpose as storefront/merchant compatibility and procurement vendor.
- `account_id` columns are nullable by design in this cycle, so authorization must continue to preserve supplier/user fallbacks.
- Marketplace service listings are not yet fully represented through `MarketplaceListing`; product listing separation is the safe minimum implemented in this cycle.
