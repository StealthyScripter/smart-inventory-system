# Phases 16-21 Marketplace Expansion Summary

## Phase 16 - Service Booking and Scheduling

- Added bookable service lifecycle records with `ServiceBooking`, `ServiceBookingItem`, and `AvailabilitySlot`.
- Customers can request services, view booking history, and cancel eligible bookings.
- Merchant users can accept, schedule, progress, complete, or cancel bookings scoped to their linked suppliers.
- In-app booking notifications are generated for important booking transitions.

## Phase 17 - Merchant/Customer Messaging

- Added `Conversation` and `Message` records for scoped customer-merchant communication.
- Added customer and merchant inboxes, unread tracking, message history, and read marking.
- Conversations can be linked to orders or service bookings without external messaging integrations.

## Phase 18 - Email Notification Delivery

- Added `NotificationEmailJob` and mailers for order, booking, review, and message events.
- Email delivery is provider-neutral and uses the existing Rails mailer/Active Job stack.
- Real payment provider and external notification providers remain future work.

## Phase 19 - Advanced Search and Discovery

- Added `SearchService` and public `/search` discovery across products, services, merchants, and categories.
- Added searchable tag metadata for products, service listings, and suppliers.
- Search remains database-backed; Meilisearch/Elasticsearch are deferred until scale requires them.

## Phase 20 - Admin Moderation and Marketplace Governance

- Added `Report` and `ModerationAction` models.
- Added admin-only governance tools for hiding products/services/reviews, suspending merchants, and resolving reports.
- Moderation actions are logged durably for auditability.

## Phase 21 - Production Hardening and Demo Data

- Enabled a conservative Content Security Policy compatible with the current Rails server-rendered UI.
- Added composite indexes for common marketplace discovery, messaging, review, and booking query paths.
- Added idempotent demo marketplace seed data for merchants, products, services, customers, orders, bookings, reviews, payments, and notifications.

## Deferred Work

- Real payment provider integration remains deferred. The manual/test provider abstraction should be extended with provider-specific signature verification, idempotency handling, refund APIs, and reconciliation jobs when credentials and provider choice are finalized.
- RFQs, auctions, Jenga PM integration, push notifications, microservices, and external search infrastructure remain outside this cycle.
