# 09 Reviews And Ratings

## Goals

- Allow customers to review purchased products/merchants.

## Dependencies

- Delivered orders.
- Customer portal.

## Models

- `Review`
- `RatingSummary`

## Migrations

- Reviews with product, supplier, user, order item, rating, body, status.
- Counter caches or summary table.

## Controllers

- `ReviewsController`
- `Admin::ReviewsController`

## Policies

- Customers can review purchased delivered items.
- Admin can moderate reviews.
- Merchants can respond if responses are added.

## Services

- Review eligibility service.
- Rating rollup service.

## Jobs

- Rating summary recalculation.

## Routes

- Product review routes.
- Admin moderation routes.

## Views

- Product review list.
- Review form.
- Admin moderation queue.

## Tests

- Purchase verification.
- Rating bounds.
- Moderation permissions.

