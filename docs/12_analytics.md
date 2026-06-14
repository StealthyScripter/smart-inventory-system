# 12 Analytics

## Goals

- Expand from inventory dashboard metrics to marketplace analytics.

## Dependencies

- Orders.
- Payments.
- Fulfillment.
- Reviews.

## Models

- `AnalyticsSnapshot`
- `SalesMetric`
- `InventoryMetric`

## Migrations

- Rollup tables for daily merchant/product/order metrics.

## Controllers

- `Admin::AnalyticsController`
- `Merchant::AnalyticsController`

## Policies

- Admin sees platform-wide analytics.
- Merchant sees own supplier/product/order analytics.

## Services

- Sales rollup service.
- Inventory turnover calculation.
- Low-stock forecasting service.

## Jobs

- Nightly analytics rollups.
- Report export generation.

## Routes

- Admin analytics.
- Merchant analytics.

## Views

- Sales dashboards.
- Inventory turnover reports.
- Low-stock and demand views.
- Export screens.

## Tests

- Metric calculations.
- Merchant scoping.
- Report generation jobs.

