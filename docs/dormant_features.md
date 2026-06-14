# Dormant Features

## Summary

The schema contains operational marketplace-adjacent tables that are not wired into active Rails models, routes, controllers, or views.

## Purchase Orders

Existing assets:

- `purchase_orders` table.
- `purchase_order_items` table.
- Foreign keys to `suppliers`, `users`, and `products`.
- Status string with default `pending`.
- Order totals and expected delivery date fields.

Missing pieces:

- `PurchaseOrder` model.
- `PurchaseOrderItem` model.
- Routes.
- Controller.
- Views.
- Authorization rules.
- Stock receipt workflow.
- Tests.

Relationships:

- Supplier has many purchase orders.
- User creates purchase orders.
- Purchase order has many purchase order items.
- Purchase order item belongs to product.
- Stock movements can reference purchase orders through polymorphic `reference_type` and `reference_id`.

## Sales Transactions

Existing assets:

- `sales_transactions` table.
- Foreign keys to `products`, `locations`, and `users`.
- Quantity, unit price, total amount, customer name, transaction date.
- `StockMovement` enum includes `sale`.

Missing pieces:

- `SalesTransaction` model.
- Routes.
- Controller.
- Views.
- Inventory deduction workflow.
- Customer account relationship.
- Payment relationship.
- Tests.

## Demand Forecasts

Existing assets:

- `demand_forecasts` table.
- Foreign keys to `products` and `locations`.
- Forecast date, period type, predicted demand, confidence score.
- Unique index by product, location, date, and period.

Missing pieces:

- `DemandForecast` model.
- Forecast generation service/job.
- Dashboard/reporting UI.
- Import/export.
- Tests.

## Categories

Categories are active through product associations but partially dormant operationally.

Existing assets:

- `Category` model.
- `categories` table.
- Product form selects categories.
- Seed data.

Missing pieces:

- Category controller.
- Category management UI.
- Category-level authorization.
- Category specs.

