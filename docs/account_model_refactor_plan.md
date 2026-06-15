# Account Model Refactor Plan

## Implementation status

The v1.1.0 account-model cycle implemented the account foundation, supplier compatibility layer, account membership permissions, customer/merchant onboarding entry points, enterprise settings/member management, nullable account ownership references, a safe `MarketplaceListing` product layer, customer-first root/catalog routing, merchant dashboard realignment, idempotent account backfill, and security audit documentation.

Deferred cleanup:

- Remove or narrow legacy `SupplierUser` fallback only after production backfill is verified.
- Continue separating service marketplace listings into `MarketplaceListing`.
- Consider non-null account references after legacy data is fully migrated.

## Current ownership model

The application currently uses `User#role` for platform-level authorization and uses `Supplier` as the merchant ownership boundary.

Current merchant-facing ownership is centered on:

- `Supplier`: merchant storefront, product owner, service provider, order item fulfiller, booking provider, review target, conversation participant, and procurement supplier.
- `SupplierUser`: join table connecting users with supplier records. A user with platform role `supplier` and at least one `SupplierUser` row can access the merchant portal.
- `Product#supplier_id`: merchant/product ownership and procurement supplier reference.
- `ServiceListing#supplier_id`: merchant service provider ownership.
- `OrderItem#supplier_id`: merchant fulfillment ownership.
- `ServiceBooking#supplier_id`: merchant service booking ownership.
- `Conversation#supplier_id`: merchant side of buyer/merchant messaging.
- `Review#supplier_id`: merchant review aggregation target.

Customer ownership is currently direct user ownership:

- `Cart#user_id`
- `Order#user_id`
- `ServiceBooking#user_id`
- `Conversation#customer_id`
- `Review#user_id`
- `Notification#user_id`
- `Report#reporter_id`

Back-office inventory ownership is still platform/location oriented:

- `User#role` includes inventory roles such as `regional_manager`, `location_manager`, `department_manager`, and `employee`.
- `Location#manager_id`
- `StockLevel` belongs to product/location.
- `StockMovement` belongs to product/user and optional source/destination locations.
- `PurchaseOrder` belongs to supplier/user.

## Current role model

`User#role` is the only explicit role field. It mixes several concerns:

- Platform administration: `admin`, `regional_manager`.
- Internal inventory operations: `location_manager`, `department_manager`, `employee`, `client`.
- Marketplace customer behavior: `customer`.
- Marketplace merchant access: `supplier`.
- Guest/placeholder state: `guest`.

`Authorization` exposes helper methods based on `User#role`, including `supplier_user?`, `customer?`, `can_manage_products?`, `can_access_back_office?`, `manageable_suppliers`, and product ownership checks.

Merchant portal access is currently:

```ruby
supplier_user? && current_user.suppliers.exists?
```

Customer portal access is currently:

```ruby
customer?
```

Admin portal access is currently:

```ruby
admin?
```

## Current supplier and merchant assumptions

The code assumes that a supplier is the merchant account:

- Merchant dashboard, products, services, orders, inventory, analytics, shops, bookings, and conversations all scope by `merchant_suppliers`.
- Public catalog/storefront pages render supplier names and shop fields as the merchant identity.
- Notifications to merchants are sent to `supplier.users`.
- Existing tests create merchant users by assigning role `supplier` and then creating `SupplierUser`.

The same `Supplier` record also still represents procurement/vendor data:

- Purchase orders belong to suppliers.
- Products may keep a supplier for sourcing.
- Supplier deletion has inventory implications.

## Problems with SupplierUser as merchant ownership

`SupplierUser` is sufficient for the MVP but does not model the target business structure:

- It cannot distinguish individual merchant accounts from enterprise merchant accounts.
- It has no membership role, status, or lifecycle fields.
- It cannot express enterprise access control such as catalog manager, inventory manager, order manager, support staff, or viewer.
- It forces merchant access to depend on the platform role `supplier`.
- It conflates merchant ownership with supplier/procurement concepts.
- It does not provide a customer account/profile concept.
- It cannot safely support account settings, default account values, disabled memberships, or last-owner protections.
- It makes future account-scoped data migration difficult because ownership is inferred through supplier records rather than a direct account boundary.

## Target model

Introduce account-based ownership while preserving current behavior.

New records:

- `Account`
- `AccountMembership`
- `CustomerProfile`
- `MerchantProfile`

Account types:

- `customer`
- `individual_merchant`
- `enterprise_merchant`

Account statuses:

- `active`
- `suspended`
- `closed`
- `pending`

Membership roles:

- `owner`
- `admin`
- `manager`
- `catalog_manager`
- `inventory_manager`
- `order_manager`
- `service_manager`
- `support_staff`
- `employee`
- `viewer`

The platform role remains on `User#role` for existing login/session/admin/inventory behavior. Account roles live on `AccountMembership` and govern merchant/customer account access.

`Supplier` should remain available as a legacy merchant alias, storefront data source, procurement supplier, and external/vendor reference during the transition. Long-term merchant ownership should move to `Account`.

## Migration strategy

Use backward-compatible migrations and dual links:

1. Add account tables without removing existing supplier columns.
2. Add optional account/profile associations that can coexist with `Supplier` and `SupplierUser`.
3. Create account records for new customer and merchant signups.
4. Map existing supplier merchant records to merchant accounts through `MerchantProfile`.
5. Map existing `SupplierUser` rows to `AccountMembership` rows.
6. Add compatibility helpers such as `current_merchant_account`, `current_customer_account`, `current_account_membership`, `Supplier#merchant_account`, and `SupplierUser#account_membership`.
7. Gradually add nullable `account_id` references to merchant-owned/customer-owned tables.
8. Backfill account references only where the mapping is deterministic.
9. Keep legacy `supplier_id` fields until all scoped behavior and tests have account-backed equivalents.
10. Tighten validations only after data is backfilled and compatibility paths are verified.

## Compatibility strategy

During the transition:

- Existing `SupplierUser` merchant users must still reach the merchant portal.
- Existing supplier-owned products, services, orders, bookings, conversations, reviews, and analytics must remain visible.
- `User#supplier_user?` and supplier-scoped tests should continue to pass.
- New account-backed merchant helpers should prefer account membership when present and fall back to supplier membership when necessary.
- Public catalog and merchant storefront behavior should continue to use current product/service visibility rules until `MarketplaceListing` exists.
- Supplier remains the source for existing shop fields until `MerchantProfile` is wired through the UI.
- No frozen tag is modified.

## Risk analysis

Primary risks:

- Accidentally blocking existing supplier users from the merchant portal.
- Exposing customer-only data to merchant users or merchant management tools to customers.
- Duplicating ownership state inconsistently between `Supplier`, `MerchantProfile`, and `Account`.
- Breaking order, booking, messaging, review, analytics, or notification scopes during partial migration.
- Overloading `User#role` further instead of separating platform roles from account roles.
- Adding strict account references before existing data can be safely backfilled.
- Losing the procurement/vendor meaning of `Supplier`.

Risk controls:

- Keep migrations additive and nullable until backfills are proven.
- Add model tests before controller rewiring.
- Preserve current supplier specs and add account-backed specs next to them.
- Prefer adapter/helper methods over broad rewrites.
- Run RSpec, RuboCop, and Zeitwerk after every phase.
- Run Brakeman after authorization/security changes.

## Phase breakdown

### Phase 0: Plan only

Document the current system and target migration path. No application code changes.

### Phase 1: Account foundation

Add `Account`, `AccountMembership`, `CustomerProfile`, and `MerchantProfile` with validations, scopes, associations, creator/member helpers, and focused model specs. Do not rewire merchant controllers yet.

### Phase 2: Supplier/account compatibility layer

Map `Supplier` and `SupplierUser` to merchant accounts and memberships through compatibility helpers. Add controller helper methods such as `current_merchant_account`, `current_customer_account`, and `current_account_membership`.

### Phase 3: Merchant access control rework

Introduce account-role permission helpers for catalog, inventory, order, service, support, and account administration capabilities. Keep supplier fallback until all merchant accounts are backfilled.

### Phase 4: Account onboarding and separate login flows

Add `/customers/sign_in`, `/customers/sign_up`, `/merchants/sign_in`, and `/merchants/sign_up` as UX entry points over the same authentication system. Create the right account/profile/membership records during signup.

### Phase 5: Enterprise settings and users

Add enterprise account settings, profile defaults, member management, role changes, disabling, re-enabling, and last-owner/admin protections.

### Phase 6: Account-scoped ownership

Add account references to products, services, orders, bookings, conversations, notifications, reports, inventory, and related records where safe. Preserve supplier references.

### Phase 7: Marketplace listing separation

Introduce or minimally prepare `MarketplaceListing` so public listing state is separate from private inventory product data.

### Phase 8: Customer experience realignment

Make catalog the guest/customer default, adjust customer navigation, and keep inventory terminology out of customer flows.

### Phase 9: Merchant operating system realignment

Make the merchant portal account-aware and business-first, with team/settings surfaced only for enterprise roles that can use them.

### Phase 10: Data migration, seeds, and compatibility audit

Backfill accounts/profiles/memberships from users, suppliers, and supplier users. Update demo seeds to include customers, individual merchants, enterprise merchants, and enterprise employees.

### Phase 11: Security, privacy, and permission audit

Audit customer, merchant, enterprise employee, admin, catalog, messaging, booking, order, inventory, media, CSV, and analytics access. Create `docs/account_model_security_audit.md`.

### Phase 12: Final freeze check

Run full verification, update developer/security/readiness/integration docs, commit, and tag `v1.1.0-account-model` if all checks pass.

## Rollback notes

Early phases should be reversible by rolling back additive migrations:

- Phase 1 tables can be dropped if no production data depends on them.
- Phase 2 compatibility helpers can be removed without changing legacy supplier behavior.
- Supplier columns should not be removed in this cycle.
- Account references added later should remain nullable until after successful backfill and verification.
- Backfill tasks should be idempotent so they can be rerun after rollback/redeploy.
- Any destructive cleanup of `SupplierUser` or supplier ownership should be deferred to a later release after a successful account-model freeze.
