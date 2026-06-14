# Data Protection and Privacy

## Customer Data Boundaries

Customers must only access their own carts, orders, bookings, conversations, notifications, reviews, analytics, receipts, and estimates.

## Merchant Data Boundaries

Merchant users are scoped through `SupplierUser`. Merchants must only manage products, services, inventory, bookings, orders, media, conversations, CSV exports, and analytics for linked suppliers.

## Private and Local Inventory

Private, draft, archived, soft-deleted, and local-only inventory must never appear in public catalog, search, merchant storefront, or recommendation results.

## Admin Data

Reports, moderation actions, governance controls, and admin analytics are admin-only.

## TODOs Before Public Launch

- Add account deletion and export workflows.
- Define data retention rules for customers, merchants, orders, messages, reports, and media.
- Create GDPR/privacy policy procedures if operating in regulated regions.
- Add password reset, verification, rate limiting, and optional MFA.
- Review production logs for accidental personal data leakage.
