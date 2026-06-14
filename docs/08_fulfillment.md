# 08 Fulfillment

## Goals

- Support packing, shipping, delivery, cancellation, and returns.

## Dependencies

- Order management.
- Stock movement strategy.

## Models

- `Fulfillment`
- `Shipment`
- `ReturnAuthorization`
- `StockMovement`

## Migrations

- Fulfillment records.
- Shipment tracking fields.
- Return records.

## Controllers

- `Merchant::FulfillmentsController`
- `Admin::FulfillmentsController`
- `Customer::ReturnsController`

## Policies

- Merchant fulfills own orders.
- Customer requests returns for own delivered orders.
- Admin oversees all.

## Services

- Packing service.
- Shipping service.
- Delivery confirmation service.
- Return restock service.

## Jobs

- Fulfillment notifications.
- Delivery status polling only after carrier integration exists.

## Routes

- Nested fulfillment routes under orders.

## Views

- Pick/pack screens.
- Shipment detail.
- Return management.

## Tests

- Fulfillment state transitions.
- Stock deduction timing.
- Return stock movement creation.

