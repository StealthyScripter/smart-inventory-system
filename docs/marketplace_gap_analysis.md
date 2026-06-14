# Marketplace Gap Analysis

## Classification

| Capability | Status | Notes |
| --- | --- | --- |
| Merchants | CAN BE EXTENDED | `suppliers` and `supplier` role exist, but no ownership/account portal |
| Customers | CAN BE EXTENDED | `customer` role exists, but no customer domain |
| Public catalog | REQUIRES NEW IMPLEMENTATION | Product catalog is authenticated inventory UI |
| Search | REQUIRES NEW IMPLEMENTATION | No search/filtering implementation |
| Filters | REQUIRES NEW IMPLEMENTATION | Category/supplier fields exist and can seed filters |
| Cart | REQUIRES NEW IMPLEMENTATION | No cart schema |
| Checkout | REQUIRES NEW IMPLEMENTATION | No checkout workflow |
| Payments | REQUIRES NEW IMPLEMENTATION | No payment schema/integration |
| Order management | PARTIALLY EXISTS | Dormant purchase/sales tables; no customer order lifecycle |
| Shipping | REQUIRES NEW IMPLEMENTATION | No shipping model |
| Fulfillment | REQUIRES NEW IMPLEMENTATION | Stock levels and movements can support it |
| Reviews | REQUIRES NEW IMPLEMENTATION | No schema |
| Ratings | REQUIRES NEW IMPLEMENTATION | No schema |
| RFQs | REQUIRES NEW IMPLEMENTATION | No schema |
| Auctions | REQUIRES NEW IMPLEMENTATION | No schema |
| Analytics | PARTIALLY EXISTS | Inventory dashboard only |

## High-Leverage Existing Assets

- `users.role` already names marketplace actors.
- `suppliers` can become merchant organizations.
- `products` already carry catalog and pricing fields.
- `categories` already support taxonomy.
- `stock_levels.reserved_quantity` can support cart/order reservations.
- `stock_movements.reference` can tie stock changes to orders, returns, purchases, or fulfillment events.

## Primary Gaps

- No tenant/merchant ownership boundary.
- No public/customer-facing route namespace.
- No marketplace order model.
- No cart/reservation workflow.
- No payment/refund ledger.
- No fulfillment/shipping lifecycle.
- No customer account domain beyond role strings.
- No review, RFQ, auction, or analytics domains.

