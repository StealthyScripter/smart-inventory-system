# Merchant Portal Plan

## Current Supplier State

Suppliers are passive records. They have name, contact information, address, default lead time, and product associations. Supplier users exist only as a role string and are not linked to supplier records.

## Target Capabilities

- Merchant accounts tied to supplier records.
- Merchant dashboard.
- Product listing management.
- Inventory visibility and adjustments for merchant-owned products.
- Incoming order queue.
- Fulfillment actions.
- Sales analytics.

## Recommended Internal Model Evolution

- Add supplier ownership: associate users with suppliers through a join model such as `SupplierUser`.
- Preserve `Supplier` as the merchant organization record instead of creating a parallel merchant table at first.
- Add product ownership rules through existing `products.supplier_id`.
- Add merchant-scoped authorization helpers or policies before adding write access.

## Route Direction

Add a `merchant` namespace inside the same Rails app:

- `merchant/dashboard`
- `merchant/products`
- `merchant/inventory`
- `merchant/orders`
- `merchant/analytics`

## Implementation Notes

- Reuse ERB and request specs.
- Keep inventory writes backed by `StockLevel` and `StockMovement`.
- Add service objects for multi-step operations such as accepting orders and preparing fulfillment.
- Do not create a separate merchant app or service.

