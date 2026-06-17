# v1.3 Marketplace Experience Report

## What changed
- Reworked the Home page into a denser, search-centric marketplace landing experience.
- Added a dedicated Home header with logo, centered search, account area, and cart action.
- Added a horizontal category/menu strip with swipeable overflow on smaller screens.
- Expanded Home into a long sectioned marketplace page with mixed rails and grids.
- Introduced richer product, service, and merchant card partials with stronger media handling.
- Removed the old single-letter fallback look from marketplace cards in favor of icon-based placeholders.

## Public page updates
- Updated `Home`, `Catalog`, `Search`, `Services`, and `Merchant storefront` pages to reuse the richer marketplace cards.
- Kept private, local, draft, and archived listings out of public surfaces.
- Preserved catalog, services, and merchant routes and behavior.

## Header and navigation
- Home uses its own top row so it does not duplicate the account dashboard header chrome.
- Search remains prominent and centered on the marketplace landing page.
- Account and cart actions remain visible for guests and signed-in users.
- Bottom navigation remains intact for account users.

## Card diversity
- Added standard, compact, feature, and rail-style marketplace layouts.
- Added icon-based fallback media blocks for products, services, and merchants.
- Kept card actions concise: View, Book, View shop.
- Used mixed row layouts so the page feels less symmetrical and less dashboard-like.

## Typography and color
- Applied a Roboto-first font stack with system fallbacks.
- Preserved theme-specific accents for customer, merchant, and enterprise modes.
- Kept contrast and focus styling on the shared theme tokens.

## Accessibility notes
- Search fields and action links include accessible labels.
- Focus styling remains visible through the shared focus ring.
- Headings keep semantic hierarchy on the marketplace sections.
- Card fallbacks are visual and do not depend on a single-letter cue.

## Responsive notes
- Home header collapses into a single-column stack on smaller widths.
- Menu strip is horizontally scrollable.
- Rail sections remain swipeable on narrow screens.
- Shared cards and listings wrap safely without horizontal overflow in the test environment.

## Verification
- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec`
- `docker-compose run --rm -e RAILS_ENV=test app bin/rubocop`
- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check`
- `docker-compose run --rm app bundle exec brakeman`

## Remaining UI TODOs
- A live browser screenshot pass on Linux/Chrome and Firefox would still be useful against production-like data.
- Some legacy dashboard-era pages outside the marketplace flow still use older layout language.
- Section ordering could be tuned later if seed/data volume changes.
