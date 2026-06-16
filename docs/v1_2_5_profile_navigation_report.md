# v1.2.5 Profile Navigation Report

## Pages Polished

- Customer: `/customer/profile`, `/customer/orders`, `/customer/service_bookings`, `/catalog`, `/services`, `/cart`
- Merchant: `/merchant/profile`, `/merchant/catalog`, `/merchant/products`, `/merchant/inventory`, `/merchant/orders`, `/merchant/services`, `/merchant/service_bookings`
- Public: `/catalog`, `/search`, `/services`, `/merchants/:id`
- Admin/back office: `/dashboard`, `/admin`, `/admin/reports`, `/admin/moderation`, `/admin/analytics`

## Navigation Changes

- Added bottom navigation for customer accounts with Home, Shop, Services, Cart, and Profile.
- Added bottom navigation for merchant accounts with Dashboard, Catalog, Products, Inventory, and Profile.
- Added `/merchant/catalog` as a merchant catalog hub for the new bottom tab.
- Removed the customer Search tab from account navigation and replaced it with Home.
- Kept the top header clean with logo, page title, prominent search, and customer cart action only.

## Profile Hubs

- Added a customer profile hub that prominently surfaces Orders and Bookings.
- Added a merchant profile hub that prominently surfaces Orders and Bookings.
- Added merchant-specific links for catalog, products, inventory, inbox, notifications, analytics, and sign out.
- Exposed enterprise-only team, location, and access-control links only when the account has permission.

## Header and Layout Cleanup

- Removed breadcrumb/path text from the layout shell.
- Removed secondary search fields from marketplace list pages where the global header search is present.
- Removed the old username, inbox, notifications, logout, and account badge cluster from the top header.
- Added layout padding so the fixed bottom navigation does not cover content.
- Kept tables and content cards inside responsive wrappers to avoid horizontal overflow on narrow Chrome/Linux viewports.

## Theme and Contrast Updates

- Preserved distinct customer, merchant, and enterprise themes through the body class and header/nav accents.
- Tuned card, border, muted text, and badge colors for better scanability and contrast.
- Added responsive icon-label behavior in bottom navigation so small screens can collapse to icon-only labels via CSS.

## Tests Added or Updated

- Added request coverage for customer profile access, merchant profile access, enterprise-only controls, and merchant catalog routing.
- Added layout checks for breadcrumb removal, header search deduplication, theme classes, and bottom navigation rendering.
- Updated existing navigation and dashboard request specs to match the cleaned layout.
- Full verification passed:
  - `docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec`
  - `docker-compose run --rm -e RAILS_ENV=test app bin/rubocop`
  - `docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check`
  - `docker-compose run --rm app bundle exec brakeman`

## Remaining UI TODOs

- Customer profile editing is still represented as a hub action rather than a full edit form.
- Merchant catalog is a hub page that surfaces existing product and service collections, not a brand-new management workflow.
- Admin navigation is preserved in the compact sidebar shell and could be normalized further in a later UI pass.
