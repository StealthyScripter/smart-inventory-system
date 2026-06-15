# Payment Provider Integration

## Current state

The payment layer is provider-ready and keeps the manual/test provider as the default. Live credentials are not required for tests.

Supported provider keys:

- `manual`
- `stripe`

## Architecture

Provider-specific behavior lives behind payment provider adapters:

- `PaymentProviders::ManualProvider`
- `PaymentProviders::StripeProvider`
- `PaymentProviders::Registry`

`PaymentService#create_payment!` chooses the provider adapter and creates a pending payment. `PaymentWebhookService` verifies webhook signatures through the selected adapter and processes idempotent webhook events through `WebhookEvent`.

## Required environment variables

Manual/test provider:

```sh
MANUAL_PAYMENT_WEBHOOK_SECRET=...
```

Stripe-ready provider:

```sh
STRIPE_SECRET_KEY=...
STRIPE_WEBHOOK_SECRET=...
```

No payment secrets should be committed. Missing Stripe credentials fail safely and do not create a payment.

## Webhooks

Manual webhook:

```text
POST /webhooks/payments/manual
Header: X-Manual-Signature
```

Stripe-ready webhook:

```text
POST /webhooks/payments/stripe
Header: X-Stripe-Signature
```

Webhook payloads are processed idempotently by provider and external event ID. Duplicate processed events are ignored.

## Stripe integration notes

This release does not require the Stripe gem or live API calls. The adapter is ready for the next step:

- replace placeholder payment creation with Checkout Session or Payment Intent creation
- store the Stripe payment/session ID as `provider_reference`
- use Stripe's official signature verification if the gem is added
- map Stripe event types to `payment.paid`, `payment.failed`, refund, and dispute handling

## Refund readiness

`Payment` already supports `refunded` status. Provider refund identifiers and refund workflows should be added in a dedicated payment hardening phase.
