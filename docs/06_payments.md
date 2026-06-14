# 06 Payments

## Goals

- Add internal payment ledger and first provider integration.

## Dependencies

- Cart and checkout.
- Order lifecycle.

## Models

- `Payment`
- `PaymentAttempt`
- `Refund`
- `WebhookEvent`

## Migrations

- Payment ledger tables.
- Provider references and idempotency keys.

## Controllers

- `PaymentsController`
- `RefundsController`
- `Webhooks::PaymentsController`

## Policies

- Customers can view own payments.
- Admins can manage refunds.
- Merchants can view payments for own orders if marketplace settlement is in scope.

## Services

- Provider adapter POROs.
- Payment confirmation service.
- Refund service.
- Webhook processing service.

## Jobs

- Process payment webhooks.
- Retry provider reconciliation.

## Routes

- Payment routes under checkout/order context.
- Webhook routes under provider-specific paths.

## Views

- Payment status.
- Refund admin screens.

## Tests

- Signature verification.
- Idempotent webhook processing.
- Payment state transitions.

