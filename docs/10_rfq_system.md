# 10 RFQ System

## Goals

- Support request-for-quote workflows for B2B buying.

## Dependencies

- Customer accounts.
- Merchant accounts.
- Product/catalog foundations.

## Models

- `RequestForQuote`
- `RfqItem`
- `RfqResponse`
- `RfqMessage`

## Migrations

- RFQ header/items.
- Supplier invitations/responses.
- Status history if needed.

## Controllers

- `Customer::RfqsController`
- `Merchant::RfqResponsesController`
- `Admin::RfqsController`

## Policies

- Customer owns submitted RFQs.
- Invited merchants can respond.
- Admin can oversee.

## Services

- RFQ submission service.
- Merchant matching/invitation service.
- Quote acceptance service.

## Jobs

- RFQ invitation notifications.
- Deadline reminders.

## Routes

- Customer RFQ resources.
- Merchant RFQ response resources.

## Views

- RFQ builder.
- Merchant quote response.
- Quote comparison.

## Tests

- Merchant invitation restrictions.
- Quote acceptance state changes.
- RFQ deadline behavior.

