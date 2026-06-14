# 11 Auction System

## Goals

- Support auction-style marketplace listings.

## Dependencies

- Marketplace listings.
- Customer accounts.
- Payments/order lifecycle.

## Models

- `Auction`
- `Bid`
- `AuctionWatch`

## Migrations

- Auction fields: product/listing, start/end time, reserve price, status.
- Bids with bidder, amount, timestamp.

## Controllers

- `AuctionsController`
- `Customer::BidsController`
- `Merchant::AuctionsController`

## Policies

- Merchants manage own auctions.
- Customers bid on active auctions.
- Admin can moderate.

## Services

- Bid placement service.
- Auction closing service.
- Winner order creation service.

## Jobs

- Auction close job.
- Bid notifications.

## Routes

- Public auction index/show.
- Customer bid routes.
- Merchant auction management.

## Views

- Auction listing/detail.
- Bid form.
- Merchant auction setup.

## Tests

- Bid validation.
- Concurrent bid handling.
- Auction close and order creation.

