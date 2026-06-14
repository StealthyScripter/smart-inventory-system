# Payments Architecture

## Scope Boundary

Payments are not implemented. This document describes future in-repository architecture only. No external integration should be built before marketplace order and checkout foundations exist.

## Supported Providers

Future providers:

- Stripe
- PayPal
- M-Pesa

## Internal Models

Recommended internal models:

- `Payment`: order, provider, provider reference, amount, currency, status.
- `PaymentAttempt`: request/response metadata for retries.
- `Refund`: payment, amount, reason, status.
- `WebhookEvent`: provider, external id, event type, payload, processing status.

## Payment Flow

1. Customer creates order from checkout.
2. Inventory is reserved.
3. Payment attempt is created.
4. Provider checkout/authorization is initiated.
5. Webhook confirms payment.
6. Order moves to confirmed.
7. Fulfillment begins.

## Refund Flow

1. Admin/merchant initiates refund.
2. Refund record is created.
3. Provider refund request is queued.
4. Webhook or API response confirms status.
5. Order/payment ledger is updated.
6. Inventory return workflow runs if applicable.

## Webhook Architecture

- Add provider-specific controllers under a namespace such as `webhooks/payments`.
- Store raw webhook payloads in `WebhookEvent` before processing.
- Verify provider signatures.
- Process idempotently through Solid Queue jobs.
- Never trust frontend payment status as final.

## Provider Notes

- Stripe: best initial provider because Rails ecosystem support is mature.
- PayPal: add after internal payment abstractions are stable.
- M-Pesa: add as a regional provider with explicit currency, phone-number, callback, and reconciliation handling.

