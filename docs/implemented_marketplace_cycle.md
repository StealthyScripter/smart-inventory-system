# Implemented Marketplace Cycle

## Summary

The marketplace expansion now includes foundation authorization, marketplace
product visibility, merchant-scoped product/inventory/order workflows, public
catalog browsing, customer carts and draft checkout orders, manual payment
ledger/webhook structure, fulfillment transitions, customer order history,
reviews, notifications, and scoped analytics.

## Deferred

- RFQs and auctions remain excluded.
- External payment, delivery, identity, and Jenga PM integrations remain
  deferred.
- Payment provider implementation currently uses a manual/test provider
  abstraction with signed simulated webhooks.
