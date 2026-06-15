# Data Protection and Privacy

## Customer Data Boundaries

Customers must only access their own carts, orders, bookings, conversations, notifications, reviews, analytics, receipts, and estimates. New customer ownership is account-backed through `Account`, `AccountMembership`, and `CustomerProfile`, while legacy user ownership remains supported.

## Merchant Data Boundaries

Merchant users are scoped through account memberships when available and through `SupplierUser` as a legacy compatibility path. Merchants must only manage products, services, inventory, bookings, orders, media, conversations, CSV exports, and analytics for their merchant account or linked suppliers.

Enterprise members must be authorized by `AccountMembership` role permissions. Customers must not see merchant management tools unless they also belong to a merchant account.

## Private and Local Inventory

Private, draft, archived, soft-deleted, hidden-listing, and local-only inventory must never appear in public catalog, search, merchant storefront, or recommendation results. Product public discovery is controlled through `MarketplaceListing` visibility.

## Admin Data

Reports, moderation actions, governance controls, and admin analytics are admin-only.

## TODOs Before Public Launch

- Add account deletion and export workflows.
- Define data retention rules for customers, merchants, orders, messages, reports, and media.
- Create GDPR/privacy policy procedures if operating in regulated regions.
- Add password reset, verification, rate limiting, and optional MFA.
- Review production logs for accidental personal data leakage.
