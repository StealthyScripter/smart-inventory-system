# 02 Marketplace Core

## Goals

- Establish marketplace domain primitives in the existing Rails app.
- Keep current inventory management working.

## Dependencies

- Foundations complete.
- Authorization matrix in place.

## Models

- `Merchant` or extend `Supplier` as merchant organization.
- `SupplierUser`
- `CustomerProfile`
- `MarketplaceListing` if product listings need to diverge from internal products.

## Migrations

- Supplier ownership fields or join table.
- Customer profile table.
- Product listing visibility/status fields.

## Controllers

- Public catalog controller.
- Merchant namespace base controller.
- Customer namespace base controller.

## Policies

- Merchant can manage own supplier/products.
- Customer can manage own profile/cart/orders.
- Back-office roles retain inventory access.

## Services

- Listing publication service.

## Jobs

- Search indexing job if search is added in this phase.

## Routes

- `catalog`
- `merchant`
- `customer`

## Views

- Public catalog index/show.
- Merchant dashboard shell.
- Customer account shell.

## Tests

- Public catalog access.
- Merchant ownership restrictions.
- Customer account access restrictions.

