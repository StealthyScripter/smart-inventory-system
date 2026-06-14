# 05 Cart And Checkout

## Goals

- Add cart and checkout workflow using existing product and stock data.

## Dependencies

- Customer portal.
- Order lifecycle design.

## Models

- `Cart`
- `CartItem`
- `Order`
- `OrderItem`
- `StockReservation`

## Migrations

- Carts and cart items.
- Orders and order items.
- Stock reservations with expiration.

## Controllers

- `CartController`
- `CheckoutController`

## Policies

- Guests may use session cart if desired.
- Authenticated customers own persistent carts and orders.

## Services

- `CartPricingService`
- `CheckoutService`
- `StockReservationService`

## Jobs

- Expire stale stock reservations.

## Routes

- `resource :cart`
- `resource :checkout`

## Views

- Cart page.
- Checkout shipping/payment review.
- Order confirmation.

## Tests

- Cart quantity validation.
- Checkout reservation.
- Reservation release on failure.

