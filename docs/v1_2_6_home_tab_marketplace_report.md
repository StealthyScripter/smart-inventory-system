# v1.2.6 Home Tab Marketplace Report

## What Changed

- Restored the customer `Home` tab as a marketplace landing page instead of a simple product list.
- Kept customer bottom navigation unchanged:
  - Home
  - Shop
  - Services
  - Cart
  - Profile
- Moved `Home` to `/` and kept `Shop` on the catalog page.

## Landing Page Sections

- Hero area with marketplace search and quick links.
- Goods section with public product previews.
- Services section with public service previews.
- Merchants section with public storefront previews.
- Recommended section using existing public product data.
- Top rated section using existing rating data.
- Recently added section using recent public goods and services.
- Continue shopping panel when the customer has an active cart.

## Visibility and Cleanup

- Public landing content only uses public listings.
- Private, local, draft, and archived items remain hidden.
- Customer top-bar search is hidden on the Home page so the landing hero stays clean.

## Tests Added or Updated

- Added request coverage for guest access to Home.
- Added request coverage for landing page sections.
- Added request coverage for hiding non-public listings.
- Updated navigation and root-page assertions to match the marketplace landing experience.
- Full verification passed:
  - `docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec`
  - `docker-compose run --rm -e RAILS_ENV=test app bin/rubocop`
  - `docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check`
  - `docker-compose run --rm app bundle exec brakeman`

## Remaining UI Notes

- The landing page uses existing marketplace data only; no new recommendation engine was added.
- The top-rated and recommended blocks fall back to live public catalog data when rating or cart data is sparse.
