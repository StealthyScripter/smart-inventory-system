# 04 Customer Portal

## Goals

- Build customer-facing storefront and account area.

## Dependencies

- Marketplace core.
- Public catalog.

## Models

- `User`
- `CustomerProfile`
- `SavedItem`
- `Order`

## Migrations

- Customer profile table.
- Saved items table.

## Controllers

- `CatalogController`
- `Customer::DashboardController`
- `Customer::OrdersController`
- `Customer::SavedItemsController`

## Policies

- Customers can access only their own customer resources.

## Services

- Recommendation service placeholder using local product/order data.

## Jobs

- Recommendation refresh job later, not initially.

## Routes

- Public catalog routes.
- `namespace :customer`.

## Views

- Storefront listing.
- Product detail.
- Customer order history.
- Saved items.

## Tests

- Public users can browse allowed catalog fields.
- Customers cannot access other customers' account data.

