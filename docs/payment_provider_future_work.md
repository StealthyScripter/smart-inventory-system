# Payment Provider Future Work

The current marketplace payment layer intentionally uses a manual/test provider
with signed simulated webhooks. Real provider integration is deferred.

Future provider work should:

- Keep `Payment`, `WebhookEvent`, `PaymentService`, and `PaymentWebhookService`
  as the internal abstraction boundary.
- Add provider adapters for Stripe, PayPal, or regional providers without
  hardcoding secrets.
- Store provider credentials in environment variables or Rails credentials.
- Verify webhook signatures before processing events.
- Preserve idempotent webhook handling through `WebhookEvent`.
