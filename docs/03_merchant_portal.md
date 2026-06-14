# 03 Merchant Portal

## Goals

- Give suppliers active merchant capabilities.
- Allow merchant-owned product and inventory management.

## Dependencies

- Marketplace core.
- Supplier-user ownership.

## Models

- `Supplier`
- `SupplierUser`
- `Product`
- `StockLevel`
- `Order`

## Migrations

- Add merchant status/profile fields to suppliers if needed.
- Add product publishing/status fields.

## Controllers

- `Merchant::DashboardController`
- `Merchant::ProductsController`
- `Merchant::InventoryController`
- `Merchant::OrdersController`
- `Merchant::AnalyticsController`

## Policies

- Merchant users can manage only their supplier-owned products and orders.

## Services

- Merchant product publishing.
- Merchant inventory adjustment.

## Jobs

- Merchant analytics rollups.

## Routes

- `namespace :merchant`.

## Views

- Merchant dashboard.
- Product management.
- Inventory.
- Incoming orders.
- Sales analytics.

## Tests

- Merchant cannot access another merchant's products/orders.
- Merchant can update allowed listing fields.

