# 07 Order Management

## Goals

- Build operational order management for customers, merchants, and admins.

## Dependencies

- Checkout.
- Payments.

## Models

- `Order`
- `OrderItem`
- `OrderStatusEvent`
- `StockMovement`

## Migrations

- Order status history.
- Order numbering.

## Controllers

- `Admin::OrdersController`
- `Merchant::OrdersController`
- `Customer::OrdersController`

## Policies

- Admin sees all orders.
- Merchant sees own supplier orders.
- Customer sees own orders.

## Services

- Order confirmation.
- Order cancellation.
- Return initiation.

## Jobs

- Order notification delivery.

## Routes

- Namespaced order resources.

## Views

- Order index/detail for each role.
- Status transition controls.

## Tests

- State transition permissions.
- Inventory effects.
- Customer/merchant/admin access isolation.

