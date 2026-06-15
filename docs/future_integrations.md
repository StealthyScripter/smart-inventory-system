# Future Integrations

The following items are intentionally deferred beyond the code-freeze milestone.

## Real Payment Providers

Keep the manual/test payment abstraction intact. Future provider work should add a provider adapter, signed webhook verification, idempotency handling, refund flows, and operational reconciliation.

## Jenga PM Integration

Do not couple Smart Inventory to external project management systems until ownership, identity, and data synchronization boundaries are designed and approved.

Any future integration must use account IDs and membership permissions as the ownership boundary. Do not integrate against legacy `SupplierUser` as the source of truth.

## Push Notifications

In-app notifications, email, and digest jobs exist. Push notifications remain deferred until device registration, opt-in, and delivery provider choices are defined.

## External Search

Current search uses Rails/database capabilities. Elasticsearch, Meilisearch, or another external search system should be considered only after measuring production query volume and relevance requirements.

## RFQs and Auctions

RFQs and auctions remain future marketplace modules. They should be implemented as separate, scoped phases with dedicated authorization, lifecycle, and testing plans.

Future RFQ/auction ownership should attach to merchant accounts and marketplace listings, not directly to private inventory products.

## Scaling Improvements

Future work should include PostgreSQL migration, durable object storage, cached analytics rollups, structured logging, rate limiting, and production-grade observability.
