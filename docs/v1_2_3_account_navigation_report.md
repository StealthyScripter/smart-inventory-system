# v1.2.3 Account Navigation Report

## Completed

- Added account-aware navigation helpers and theme body classes for customer, individual merchant, and enterprise merchant accounts.
- Updated customer navigation labels to Home and Shop, and added a Profile entry.
- Added a customer Profile hub with prominent Orders and Bookings cards plus edit profile, lists, previous orders, inbox, notifications, and sign out actions.
- Updated merchant navigation to emphasize Dashboard, Catalog, Products, Inventory, Orders, Services, Bookings, Messages, Analytics, and Profile.
- Added a merchant Catalog preview page scoped to the logged-in merchant's own marketplace product listings, with listing visibility/status badges.
- Updated merchant Services to read as a marketplace preview with status, visibility, price, and listing state.
- Clarified merchant Products as internal product records with SKU/barcode, linked marketplace status, create/edit listing, edit product, and duplicate actions.
- Updated merchant Inventory to group stock by product with location breakdowns and marketplace/private actions backed by existing product listing scope and marketplace listing behavior.
- Added merchant Profile business/company information display for individual and enterprise merchant accounts.
- Added nullable MerchantProfile fields for location, company size, contact information, business category, permits/licenses, and controlled goods indicators.
- Kept team/member and multiple-user/location profile tools enterprise-only and behind existing membership permissions.

## Verification

```sh
docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec
docker-compose run --rm -e RAILS_ENV=test app bin/rubocop
docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check
docker-compose run --rm app bundle exec brakeman
```

Results:

- RSpec: 310 examples, 0 failures
- RuboCop: 243 files inspected, no offenses detected
- Zeitwerk: All is good
- Brakeman: 0 security warnings
