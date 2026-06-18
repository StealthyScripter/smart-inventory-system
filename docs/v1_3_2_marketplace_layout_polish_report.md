# v1.3.2 Marketplace Layout Polish

## Card density

- Reduced shared card padding, grid gaps, media height, and action size.
- Standardized product, service, merchant, order, booking, profile, and metric cards.
- Added compact booking cards for customer and merchant booking summaries.
- Kept customer product cards limited to public listing data.

## Product pages

- Tightened catalog grids and filters.
- Improved product detail media, gallery, price, merchant, rating, availability, description, cart, and merchant actions.
- Reused compact product cards for recommendations.
- Reworked merchant product management into cards with clear inventory, marketplace, private/local, status, price, and stock labels.
- Split merchant product forms into inventory-product and customer-facing marketplace-listing sections.

## Service pages

- Added a scannable service-category strip.
- Made service category the primary card label while retaining the specific offering as secondary context.
- Kept provider, starting price or quote-required state, rating, availability, and scheduling actions visible.
- Polished the existing service booking form and recommendation cards without changing booking behavior.

## Profile pages

- Kept Orders and Bookings as the two prominent customer and merchant cards.
- Reduced duplicate explanatory copy and duplicate navigation.
- Converted secondary actions into compact account-hub cards.
- Limited Team, Locations, and account Settings cards to enterprise merchants.
- Kept individual merchant profiles free of enterprise-only controls.

## Supporting page cleanup

- Tightened cart, checkout, orders, bookings, conversations, notifications, search, merchant catalog, inventory, products, and services.
- Replaced the merchant product management table and search category table with responsive cards/chips.
- Applied shared density rules to merchant dashboards, analytics, and admin card pages.
- Improved empty-state spacing and action placement globally.

## Accessibility and contrast

- Preserved accessible button and input touch targets.
- Added descriptive media links, image alternatives, checkbox labels, category navigation labels, and visible keyboard focus.
- Added dark-mode surface, border, badge, link, and form-label contrast rules.
- Confirmed customer-facing product views do not render SKU, unit cost, reorder point, lead time, or stock quantities.

## Responsive notes

- Verified the public home page at 1440px desktop width in Chrome/Linux.
- Verified the services page at 390px mobile width.
- Verified the catalog at 1024px with dark mode enabled.
- Reduced mobile card media height and preserved single-column forms and full-width primary actions.
- Adjusted tablet filters to avoid cropped controls and excessive button width.

## Verification

- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec`
  - 323 examples, 0 failures
- `docker-compose run --rm -e RAILS_ENV=test app bin/rubocop`
  - 246 files inspected, no offenses
- `docker-compose run --rm -e RAILS_ENV=test app bundle exec rails zeitwerk:check`
  - All is good
- `docker-compose run --rm app bundle exec brakeman`
  - 0 security warnings

## Remaining UI TODOs

- Add purpose-built product and service photography where seeded records still use fallbacks.
- Add automated visual regression snapshots for desktop, tablet, mobile, light, and dark modes.
- Consider a future dedicated customer profile edit route; v1.3.2 preserves the existing profile behavior.
