# Notifications

## Current State

There is no domain notification system.

Existing notification-like behavior:

- Rails flash messages in controllers/views.
- `ApplicationMailer` base class.
- Mailer layouts.
- PWA service worker placeholder comments for web push notification handling.
- User role changes are logged to Rails logger with a security warning.

Missing:

- Notification model.
- Mailer classes.
- Delivery jobs.
- In-app notification center.
- User notification preferences.
- Web push subscription storage.
- Notification tests.

## Marketplace Direction

Add notifications incrementally:

1. In-app notifications backed by a `notifications` table.
2. Email mailers for account, order, fulfillment, RFQ, auction, and payment events.
3. Solid Queue jobs for delivery.
4. Optional web push after in-app/email notifications are stable.

